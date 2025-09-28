import { http } from './http'

// Clocks API service (Phoenix routes): list and toggle per user
export const clockinsApi = {
  // GET /api/clocks/:user_id
  listByUser: (userId) => http.get(`/api/clocks/${userId}`),

  // POST /api/clocks/:user_id -> toggles arrival/departure
  toggleForUser: (userId) => http.post(`/api/clocks/${userId}`)
}
