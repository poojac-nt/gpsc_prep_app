import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";

console.log("Test notification function loaded.");

interface Test {
  id: number;
  duration: number;
  name: string;
  no_questions: number;
}

interface WebhookPayload {
  type: "INSERT";
  table: string;
  record: Test;
  schema: "public";
  old_record: null | Test;
}

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve(async (req) => {
  const payload: WebhookPayload = await req.json();

  const { data: users, error } = await supabase
    .from("users")
    .select("fcm_token")
    .not("fcm_token", "is", null);

  if (error || !users?.length) {
    console.error("No users with FCM tokens found.", error);
    return new Response(JSON.stringify({ error: "No FCM tokens found" }), {
      status: 404,
    });
  }

  const accessToken = await getAccessToken({
    clientEmail: Deno.env.get("FCM_CLIENT_EMAIL")!,
    privateKey: Deno.env.get("FCM_PRIVATE_KEY")!,
  });

  const projectId = Deno.env.get("FCM_PROJECT_ID")!;

  // Notify all users
  for (const user of users) {
    const token = user.fcm_token;
    const messagePayload = {
      message: {
        token,
        notification: {
          title: "New Test Available",
          body: `Test "${payload.record.name}" has been uploaded.`,
        },
      },
    };

    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify(messagePayload),
      },
    );

    if (!fcmRes.ok) {
      const resErr = await fcmRes.text();
      console.error("FCM error for token", token, resErr);
    }
  }

  return new Response(JSON.stringify({ success: true }), {
    headers: { "Content-Type": "application/json" },
  });
});

function getAccessToken({
  clientEmail,
  privateKey,
}: {
  clientEmail: string | undefined;
  privateKey: string | undefined;
}): Promise<string> {
  if (!clientEmail || !privateKey) {
    throw new Error("Missing clientEmail or privateKey from environment");
  }

  const fixedKey = privateKey.replace(/\\n/g, "\n");

  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: fixedKey,
      scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
    });

    jwtClient.authorize((err, tokens) => {
      if (err || !tokens?.access_token) {
        reject(err ?? "No access token");
      } else {
        resolve(tokens.access_token);
      }
    });
  });
}
