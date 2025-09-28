import { createRouter, createWebHistory } from 'vue-router'

// Lazy-loaded views
const LoginView = () => import('../views/LoginView.vue')
const SignupView = () => import('../views/SignupView.vue')
const DashboardView = () => import('../views/DashboardView.vue')
const UsersView = () => import('../views/UsersView.vue')
const WorkingTimesView = () => import('../views/WorkingTimesView.vue')
const ClockinsView = () => import('../views/ClockinsView.vue')

const routes = [
  { path: '/', redirect: '/login' },
  { path: '/login', name: 'login', component: LoginView },
  { path: '/signup', name: 'signup', component: SignupView },
  { path: '/dashboard', name: 'dashboard', component: DashboardView },
  { path: '/users', name: 'users', component: UsersView },
  { path: '/working-times', name: 'working-times', component: WorkingTimesView },
  { path: '/clockins', name: 'clockins', component: ClockinsView },
]

export const router = createRouter({
  history: createWebHistory(),
  routes,
})

