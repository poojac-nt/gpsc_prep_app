import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";
console.log("Study material notification function loaded.");
const supabase = createClient(Deno.env.get("SUPABASE_URL"), Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"));
Deno.serve(async (req)=>{
  const payload = await req.json();
  const { data: users, error } = await supabase.from("users").select("fcm_token").not("fcm_token", "is", null);
  if (error || !users?.length) {
    console.error("No users with FCM tokens found.", error);
    return new Response(JSON.stringify({
      error: "No FCM tokens found"
    }), {
      status: 404
    });
  }
  const accessToken = await getAccessToken({
    clientEmail: Deno.env.get("FCM_CLIENT_EMAIL"),
    privateKey: Deno.env.get("FCM_PRIVATE_KEY")
  });
  const projectId = Deno.env.get("FCM_PROJECT_ID");
  // ✅ Send notification to all users
  for (const user of users){
    const messagePayload = {
      message: {
        token: user.fcm_token,
        notification: {
          title: "New Study Material Available",
          body: payload.record.test_id ? `New material for Test ID ${payload.record.test_id}: ${payload.record.title}` : `New study material uploaded: ${payload.record.title}`
        },
        data: {
          link: payload.record.link,
          test_id: payload.record.test_id?.toString() ?? "",
          language: payload.record.language
        }
      }
    };
    const fcmRes = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`
      },
      body: JSON.stringify(messagePayload)
    });
    if (!fcmRes.ok) {
      const resErr = await fcmRes.text();
      console.error("FCM error for token", user.fcm_token, resErr);
    }
  }
  return new Response(JSON.stringify({
    success: true
  }), {
    headers: {
      "Content-Type": "application/json"
    }
  });
});
function getAccessToken({ clientEmail, privateKey }) {
  if (!clientEmail || !privateKey) {
    throw new Error("Missing FCM clientEmail or privateKey");
  }
  const fixedKey = privateKey.replace(/\\n/g, "\n");
  return new Promise((resolve, reject)=>{
    const jwtClient = new JWT({
      email: clientEmail,
      key: fixedKey,
      scopes: [
        "https://www.googleapis.com/auth/firebase.messaging"
      ]
    });
    jwtClient.authorize((err, tokens)=>{
      if (err || !tokens?.access_token) {
        reject(err ?? "No access token returned");
      } else {
        resolve(tokens.access_token);
      }
    });
  });
}
