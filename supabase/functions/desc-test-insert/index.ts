import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";
console.log("Descriptive test notification function loaded.");
const supabase = createClient(Deno.env.get("SUPABASE_URL"), Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"));
Deno.serve(async (req)=>{
  const payload = await req.json();
  // Only process inserts for the desc_tests table
  if (payload.table !== "desc_tests" || payload.type !== "INSERT") {
    return new Response(JSON.stringify({
      skipped: true
    }), {
      status: 200
    });
  }
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
  for (const user of users){
    const messagePayload = {
      message: {
        token: user.fcm_token,
        notification: {
          title: "New Descriptive Test Available",
          body: `Test: ${payload.record.name} | Questions: ${payload.record.no_questions} | Marks: ${payload.record.total_marks}`
        },
        data: {
          test_id: payload.record.id.toString(),
          name: payload.record.name,
          no_questions: payload.record.no_questions.toString(),
          total_marks: payload.record.total_marks.toString()
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
