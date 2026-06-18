// approve-mail.mjs
// No package installs required (uses native fetch in Node).
//
// Usage:
//   SUPABASE_SERVICE_ROLE_KEY=... node script/approve-mail.mjs
// Optional overrides:
//   SUPABASE_URL=https://<project-ref>.supabase.co TARGET_EMAIL=user@example.com node script/approve-mail.mjs

const SUPABASE_URL = process.env.SUPABASE_URL ?? 'https://eatblkdojlpjdscxmual.supabase.co'
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY 
const TARGET_EMAIL = process.env.TARGET_EMAIL ?? 'apple@lema.test'

if (!SUPABASE_URL) throw new Error('Missing SUPABASE_URL')
if (!SUPABASE_SERVICE_ROLE_KEY) throw new Error('Missing SUPABASE_SERVICE_ROLE_KEY')
if (!TARGET_EMAIL) throw new Error('Missing TARGET_EMAIL')

const baseUrl = SUPABASE_URL.replace(/\/+$/, '')
const authHeaders = {
  apikey: SUPABASE_SERVICE_ROLE_KEY,
  Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
}

function tryParseJson(text) {
  try {
    return JSON.parse(text)
  } catch {
    return null
  }
}

async function requestJson(path, init = {}) {
  const headers = { ...authHeaders, ...(init.headers ?? {}) }
  if (init.body != null && headers['Content-Type'] == null) {
    headers['Content-Type'] = 'application/json'
  }

  const response = await fetch(`${baseUrl}${path}`, { ...init, headers })
  const text = await response.text()
  const body = text ? tryParseJson(text) : null

  if (!response.ok) {
    const detail =
      body?.msg ??
      body?.message ??
      body?.error_description ??
      body?.error ??
      text ??
      response.statusText

    throw new Error(`Supabase API request failed (${response.status}): ${detail}`)
  }

  return body
}

async function findUserByEmail(email) {
  const normalizedEmail = email.toLowerCase()
  const perPage = 200
  let page = 1

  while (true) {
    const params = new URLSearchParams({
      page: String(page),
      per_page: String(perPage),
    })

    const data = await requestJson(`/auth/v1/admin/users?${params.toString()}`)
    const users = Array.isArray(data?.users) ? data.users : []
    const user = users.find((u) => (u?.email ?? '').toLowerCase() === normalizedEmail)

    if (user) return user
    if (users.length < perPage) return null
    page += 1
  }
}

async function run() {
  const user = await findUserByEmail(TARGET_EMAIL)

  if (!user) {
    console.log(`User not found for email: ${TARGET_EMAIL}`)
    return
  }

  const data = await requestJson(`/auth/v1/admin/users/${encodeURIComponent(user.id)}`, {
    method: 'PUT',
    body: JSON.stringify({ email_confirm: true }),
  })

  const updatedUser = data?.user ?? data

  console.log('✅ Email confirmed')
  console.log({
    id: updatedUser?.id,
    email: updatedUser?.email,
    email_confirmed_at: updatedUser?.email_confirmed_at,
  })
}

run().catch((err) => {
  console.error('❌ Failed:', err.message)
  process.exit(1)
})
