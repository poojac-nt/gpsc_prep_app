import { createClient } from "npm:@supabase/supabase-js@2.31.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY env vars");
}

const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

Deno.serve(async (req: Request) => {
  try {
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
    }

    const authHeader = req.headers.get("authorization") ?? "";
    const token = authHeader.startsWith("Bearer ") ? authHeader.split(" ")[1] : "";

    if (!token) {
      return new Response(JSON.stringify({ error: "Missing Authorization Bearer token" }), { status: 401 });
    }

    // Validate the token by calling Supabase Auth "get user" endpoint
    // This endpoint returns the user corresponding to the access token.
    const userResp = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
      method: "GET",
      headers: {
        "Authorization": `Bearer ${token}`,
        "apikey": SUPABASE_SERVICE_ROLE_KEY, // safe to include; not strictly necessary when bearer provided
      },
    });

    if (!userResp.ok) {
      // token invalid / expired
      console.error("Token validation failed:", { status: userResp.status });
      return new Response(JSON.stringify({ error: "Invalid or expired token" }), { status: 401 });
    }

    const userJson = await userResp.json().catch(() => null);
    const userId = userJson?.id ?? userJson?.data?.id ?? null;
    if (!userId) {
      console.error("Could not extract user id from /auth/v1/user response", { userJson });
      return new Response(JSON.stringify({ error: "Could not validate user token" }), { status: 401 });
    }

    // Delete the user (admin)
    const deleteResult = await admin.auth.admin.deleteUser(userId);
    const deleteErr = (deleteResult as any)?.error ?? null;
    if (deleteErr) {
      const msg = String(deleteErr.message ?? deleteErr);
      console.error("deleteUser failed:", { message: msg });

      // If FK constraint is blocking the delete, surface a helpful status
      if (/foreign key|violates constraint/i.test(msg)) {
        return new Response(JSON.stringify({
          error: "Conflict: dependent records prevent deleting this user. Contact support or remove dependents."
        }), { status: 409 });
      }

      return new Response(JSON.stringify({ error: "Failed to delete user" }), { status: 500 });
    }

    return new Response(JSON.stringify({ success: true }), { status: 200 });

  } catch (err: any) {
    console.error("Unexpected error in delete_my_account:", {
      message: err?.message ?? String(err),
      stack: err?.stack ? err.stack.split("\n").slice(0,5).join("\n") : undefined,
    });
    return new Response(JSON.stringify({ error: "Internal server error" }), { status: 500 });
  }
});
