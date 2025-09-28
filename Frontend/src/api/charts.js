import { http } from './http'

// Charts API service
export const chartsApi = {
  // GET /api/charts/hours
  totalHours: (query) => http.get('/api/charts/hours', { query }),

  // GET /api/charts/user/:user_id/hours
  hoursByUser: (userId, query) => http.get(`/api/charts/user/${userId}/hours`, { query }),

  // GET /api/charts/user/:user_id/sessions
  sessionsByUser: (userId, query) => http.get(`/api/charts/user/${userId}/sessions`, { query }),

  // GET /api/charts/user/:user_id/breaks
  breaksByUser: (userId, query) => http.get(`/api/charts/user/${userId}/breaks`, { query })
}
