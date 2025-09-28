<template>
  <section>
    <h1>Working Times</h1>
    <div class="card">
      <form class="row" @submit.prevent="createItem">
        <input v-model.trim="form.start_time" type="datetime-local" placeholder="Start" required />
        <input v-model.trim="form.end_time" type="datetime-local" placeholder="End" required />
        <button :disabled="creating">{{ creating ? 'Creating…' : 'Create' }}</button>
      </form>

      <p v-if="loading">Loading…</p>
      <p v-if="error" class="error">{{ error }}</p>

      <table v-if="!loading" class="table">
        <thead>
          <tr>
            <th>ID</th>
            <th>User</th>
            <th>Start</th>
            <th>End</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="w in list" :key="w.id">
            <td>{{ w.id }}</td>
            <td>{{ w.user_id || w.userId }}</td>
            <td>{{ fmtIso(w.start_time || w.startTime || w.start) }}</td>
            <td>{{ fmtIso(w.end_time || w.endTime || w.end) }}</td>
            <td><button class="danger" @click="removeItem(w.id)">Delete</button></td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { workingTimesApi } from '../api/workingTimes'

const list = ref([])
const loading = ref(false)
const error = ref('')
const creating = ref(false)
const form = ref({ start_time: '', end_time: '' })
const currentUserId = ref('')

const fmtIso = (iso) => {
  if (!iso) return '--'
  const d = new Date(iso)
  if (isNaN(+d)) return String(iso)
  return d.toLocaleString()
}

const load = async () => {
  loading.value = true
  error.value = ''
  try {
    if (!currentUserId.value) { list.value = []; return }
    const res = await workingTimesApi.list(currentUserId.value)
    list.value = Array.isArray(res) ? res : (Array.isArray(res?.data) ? res.data : [])
  } catch (_) {
    error.value = 'Failed to load working times'
  } finally {
    loading.value = false
  }
}

const createItem = async () => {
  creating.value = true
  try {
    // Convert datetime-local to ISO for API
    if (!currentUserId.value) return
    const payload = {
      start: new Date(form.value.start_time).toISOString(),
      end: new Date(form.value.end_time).toISOString(),
    }
    await workingTimesApi.create(currentUserId.value, payload)
    form.value = { start_time: '', end_time: '' }
    await load()
  } finally {
    creating.value = false
  }
}

const removeItem = async (id) => {
  if (!confirm('Delete this working time?')) return
  try { await workingTimesApi.remove(id); await load() } catch {}
}

onMounted(() => {
  try {
    const u = JSON.parse(localStorage.getItem('currentUser') || 'null')
    if (u?.id) currentUserId.value = String(u.id)
  } catch {}
  load()
})
</script>

<style scoped>
.card { margin-top: 1rem; padding: 1rem; background: #111827; border: 1px solid #374151; border-radius: 12px; }
.table { width: 100%; border-collapse: collapse; }
th, td { text-align: left; padding: .5rem; border-bottom: 1px solid #374151; }
.error { color: #ef4444; }
.row { display: flex; gap: .5rem; flex-wrap: wrap; margin-bottom: .75rem; }
input { padding: .45rem .6rem; border-radius: 8px; border: 1px solid #374151; background: #0b0f17; color: #e5e7eb; }
button { padding: .5rem .7rem; border-radius: 8px; background: #2563eb; color: white; border: none; font-weight: 600; }
button.danger { background: #ef4444; }
</style>

