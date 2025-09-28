<template>
  <section>
    <h1>Users</h1>
    <div class="card">
      <div class="toolbar">
        <form class="row" @submit.prevent="createUser">
          <input v-model.trim="form.firstname" placeholder="First name" required />
          <input v-model.trim="form.lastname" placeholder="Last name" required />
          <input v-model.trim="form.username" placeholder="Username" required />
          <input v-model.trim="form.email" type="email" placeholder="Email" required />
          <input v-model.trim="form.password" type="password" placeholder="Password" required />
          <button :disabled="creating">{{ creating ? 'Creating…' : 'Create' }}</button>
        </form>
      </div>
      <p v-if="loading">Loading…</p>
      <p v-if="error" class="error">{{ error }}</p>
      <table v-if="!loading" class="table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Username</th>
            <th>Email</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="u in users" :key="u.id">
            <td>{{ u.id }}</td>
            <td>{{ u.firstname || u.first_name }} {{ u.lastname || u.last_name }}</td>
            <td>{{ u.username || u.profile_name }}</td>
            <td>{{ u.email }}</td>
            <td><button class="danger" @click="remove(u.id)">Delete</button></td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { usersApi } from '../api/users'

const users = ref([])
const loading = ref(false)
const error = ref('')
const creating = ref(false)
const form = ref({ firstname: '', lastname: '', username: '', email: '', password: '' })

const load = async () => {
  loading.value = true
  error.value = ''
  try {
    const res = await usersApi.list()
    users.value = Array.isArray(res) ? res : (Array.isArray(res?.data) ? res.data : [])
  } catch (_) {
    error.value = 'Failed to load users'
  } finally {
    loading.value = false
  }
}

const createUser = async () => {
  creating.value = true
  try {
    await usersApi.create({ ...form.value })
    form.value = { firstname: '', lastname: '', username: '', email: '', password: '' }
    await load()
  } finally {
    creating.value = false
  }
}

const remove = async (id) => {
  if (!confirm('Delete this user?')) return
  try { await usersApi.remove(id); await load() } catch {}
}

onMounted(load)
</script>

<style scoped>
.card { margin-top: 1rem; padding: 1rem; background: #111827; border: 1px solid #374151; border-radius: 12px; }
.table { width: 100%; border-collapse: collapse; }
th, td { text-align: left; padding: .5rem; border-bottom: 1px solid #374151; }
.error { color: #ef4444; }
.toolbar { margin-bottom: .75rem; }
.row { display: flex; gap: .5rem; flex-wrap: wrap; }
input { padding: .45rem .6rem; border-radius: 8px; border: 1px solid #374151; background: #0b0f17; color: #e5e7eb; }
button { padding: .5rem .7rem; border-radius: 8px; background: #2563eb; color: white; border: none; font-weight: 600; }
button.danger { background: #ef4444; }
</style>
