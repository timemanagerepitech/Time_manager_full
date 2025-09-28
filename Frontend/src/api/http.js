// Lightweight HTTP client using fetch with base URL, JSON helpers, and error handling
// Usage: import { http } from './http'
// const res = await http.get('/api/users')

// Default to relative base URL so we can use Vite dev proxy to avoid CORS in development.
// You can override with VITE_API_BASE_URL (e.g., production).
const DEFAULT_BASE_URL = (typeof import.meta !== 'undefined' && import.meta.env && import.meta.env.VITE_API_BASE_URL) || ''

const buildUrl = (path, query) => {
  const base = DEFAULT_BASE_URL.replace(/\/$/, '')
  const full = `${base}${path.startsWith('/') ? '' : '/'}${path}`
  if (!query) return full
  const usp = new URLSearchParams()
  Object.entries(query).forEach(([k, v]) => {
    if (v === undefined || v === null) return
    if (Array.isArray(v)) v.forEach((vv) => usp.append(k, vv))
    else usp.append(k, v)
  })
  const qs = usp.toString()
  return qs ? `${full}?${qs}` : full
}

const handle = async (promise) => {
  const res = await promise
  const contentType = res.headers.get('content-type') || ''
  const isJson = contentType.includes('application/json')
  const body = isJson ? await res.json().catch(() => ({})) : await res.text().catch(() => '')
  if (!res.ok) {
    const error = new Error(`HTTP ${res.status} ${res.statusText}`)
    error.status = res.status
    error.body = body
    // Surface for debugging
    if (typeof console !== 'undefined') console.error('HTTP error', { url: res.url, status: res.status, body })
    throw error
  }
  return body
}

const jsonHeaders = () => ({ 'Content-Type': 'application/json', Accept: 'application/json' })
const getHeaders = () => ({ Accept: 'application/json' })

export const http = {
  get: (path, { query, headers } = {}) => handle(fetch(buildUrl(path, query), { headers: { ...getHeaders(), ...(headers || {}) } })),
  post: (path, body, { headers } = {}) => handle(fetch(buildUrl(path), { method: 'POST', headers: { ...jsonHeaders(), ...(headers || {}) }, body: body ? JSON.stringify(body) : undefined })),
  put: (path, body, { headers } = {}) => handle(fetch(buildUrl(path), { method: 'PUT', headers: { ...jsonHeaders(), ...(headers || {}) }, body: JSON.stringify(body) })),
  patch: (path, body, { headers } = {}) => handle(fetch(buildUrl(path), { method: 'PATCH', headers: { ...jsonHeaders(), ...(headers || {}) }, body: JSON.stringify(body) })),
  delete: (path, { headers } = {}) => handle(fetch(buildUrl(path), { method: 'DELETE', headers: { ...jsonHeaders(), ...(headers || {}) } }))
}

export const apiBaseUrl = DEFAULT_BASE_URL
