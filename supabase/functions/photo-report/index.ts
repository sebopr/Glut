import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const AUTO_DELETE_THRESHOLD = 5

serve(async (req) => {
  const { photo_url, spot_id } = await req.json()

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  // Count unique devices that reported this photo
  const { data: reports } = await supabase
    .from('photo_reports')
    .select('device_id')
    .eq('photo_url', photo_url)

  const uniqueCount = new Set(reports?.map((r: { device_id: string }) => r.device_id)).size
  const shouldDelete = uniqueCount >= AUTO_DELETE_THRESHOLD

  if (shouldDelete) {
    // Remove from spot_photos table
    await supabase.from('spot_photos').delete().eq('url', photo_url)

    // Remove from storage bucket
    const pathMatch = new URL(photo_url).pathname.match(
      /\/storage\/v1\/object\/public\/spot-photos\/(.+)/,
    )
    if (pathMatch) {
      await supabase.storage.from('spot-photos').remove([pathMatch[1]])
    }
  }

  // Send email via Resend
  await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${Deno.env.get('RESEND_API_KEY')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: 'Glut <reports@glut.app>',
      to: 'sebopr@gmail.com',
      subject: shouldDelete
        ? `[Glut] Photo auto-deleted after ${uniqueCount} reports`
        : `[Glut] Photo reported (${uniqueCount}/${AUTO_DELETE_THRESHOLD})`,
      html: `
        <p><strong>Spot ID:</strong> ${spot_id}</p>
        <p><strong>Photo:</strong> <a href="${photo_url}">${photo_url}</a></p>
        <p><strong>Unique reports:</strong> ${uniqueCount} / ${AUTO_DELETE_THRESHOLD}</p>
        ${shouldDelete ? '<p><strong>✅ Photo was automatically deleted from storage and the database.</strong></p>' : '<p>No action taken yet.</p>'}
      `,
    }),
  })

  return new Response('ok', { status: 200 })
})
