<template>
  <section class="card">
    <h1>Sign up</h1>
    <form @submit.prevent="onSubmit" class="form">
      <label>
        First name
        <input v-model.trim="firstName" type="text" required />
      </label>
      <label>
        Last name
        <input v-model.trim="lastName" type="text" required />
      </label>
      <label>
        Username
        <input v-model.trim="username" type="text" required />
      </label>
      <label>
        Email
        <input v-model.trim="email" type="email" required />
      </label>
      <!-- Password input shown for UX but not sent to backend (no password field in schema) -->
      <label>
        Password (not stored)
        <input v-model.trim="password" type="password" />
      </label>
      <button :disabled="loading" type="submit">{{ loading ? 'Creating…' : 'Create account' }}</button>
      <p class="error" v-if="error">{{ error }}</p>
      <p class="hint">
        Already have an account?
        <RouterLink to="/login">Sign in</RouterLink>
      </p>
    </form>
  </section>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { usersApi } from '../api/users'

const router = useRouter()
const firstName = ref('')
const lastName = ref('')
const username = ref('')
const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const onSubmit = async () => {
  loading.value = true
  error.value = ''
  try {
    const res = await usersApi.create({ username: username.value, email: email.value })
    const user = res?.data || res
    if (!user || !user.id) {
      error.value = 'Failed to create user'
      return
    }
    const withNames = { ...user, first_name: firstName.value, last_name: lastName.value }
    localStorage.setItem('currentUser', JSON.stringify(withNames))
    router.push('/dashboard')
  } catch (e) {
    error.value = 'Could not create account'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.card { max-width: 420px; margin: 3rem auto; padding: 1rem; background: #111827; border: 1px solid #374151; border-radius: 12px; }
.form { display: flex; flex-direction: column; gap: .75rem; }
input { width: 100%; padding: .5rem .6rem; border-radius: 8px; border: 1px solid #374151; background: #0b0f17; color: #e5e7eb; }
button { padding: .6rem .8rem; border-radius: 8px; background: #10b981; color: white; border: none; font-weight: 600; }
.error { color: #ef4444; }
.hint { color: #9ca3af; }
</style>
