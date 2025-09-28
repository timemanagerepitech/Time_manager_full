import { http } from './http'

// Users API service (payloads wrapped in { user: { ... } })
export const usersApi = {
  // GET /api/users
  list: (query) => http.get('/api/users', { query }),

  // GET /api/users/:id
  get: (id) => http.get(`/api/users/${id}`),

  // POST /api/users with body { user: { firstname, lastname, username, email, password } }
  create: (user) => http.post('/api/users', { user }),

  // PUT/PATCH /api/users/:id with body { user: { ...fields } }
  update: (id, user, { method = 'PUT' } = {}) =>
    method === 'PATCH' ? http.patch(`/api/users/${id}`, { user }) : http.put(`/api/users/${id}`, { user }),

  // DELETE /api/users/:id
  remove: (id) => http.delete(`/api/users/${id}`)
}
