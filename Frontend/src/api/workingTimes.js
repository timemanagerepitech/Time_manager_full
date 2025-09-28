import { http } from './http'

// Working Times API service (payloads wrapped in { working_time: { ... } })
export const workingTimesApi = {
  // GET /api/workingtime/:user_id?start&end
  list: (userId, query) => http.get(`/api/workingtime/${userId}`, { query }),

  // GET /api/workingtime/:user_id/:id
  get: (userId, id) => http.get(`/api/workingtime/${userId}/${id}`),

  // POST /api/workingtime/:user_id with body { working_time: { start_time, end_time } }
  create: (userId, working_time) => http.post(`/api/workingtime/${userId}`, { working_time }),

  // PUT/PATCH /api/workingtime/:id with body { working_time: { ...fields } }
  update: (id, working_time, { method = 'PUT' } = {}) =>
    method === 'PATCH'
      ? http.patch(`/api/workingtime/${id}`, { working_time })
      : http.put(`/api/workingtime/${id}`, { working_time }),

  // DELETE /api/workingtime/:id
  remove: (id) => http.delete(`/api/workingtime/${id}`)
}
