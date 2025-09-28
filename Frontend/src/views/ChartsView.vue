<template>
  <section>
    <h1>Charts</h1>

    <div class="card">
      <h2>Total Hours</h2>
      <form class="row" @submit.prevent="loadTotal">
        <input v-model.trim="query.range" placeholder="Range (e.g. 7d, 30d)" />
        <button :disabled="loading.total">{{ loading.total ? 'Loading…' : 'Refresh' }}</button>
      </form>
      <pre class="pre" v-if="total">{{ total }}</pre>
    </div>

    <div class="card">
      <h2>User Hours</h2>
      <form class="row" @submit.prevent="loadUserHours">
        <input v-model.trim="userId" placeholder="User ID" />
        <input v-model.trim="query2.range" placeholder="Range (e.g. 7d, 30d)" />
        <button :disabled="loading.userHours">{{ loading.userHours ? 'Loading…' : 'Refresh' }}</button>
      </form>
      <pre class="pre" v-if="userHours">{{ userHours }}</pre>
    </div>

    <div class="card">
      <h2>User Sessions</h2>
      <form class="row" @submit.prevent="loadUserSessions">
        <input v-model.trim="userId2" placeholder="User ID" />
        <input v-model.trim="query3.range" placeholder="Range (e.g. 7d, 30d)" />
        <button :disabled="loading.userSessions">{{ loading.userSessions ? 'Loading…' : 'Refresh' }}</button>
      </form>
      <pre class="pre" v-if="userSessions">{{ userSessions }}</pre>
    </div>

    <div class="card">
      <h2>User Breaks</h2>
      <form class="row" @submit.prevent="loadUserBreaks">
        <input v-model.trim="userId3" placeholder="User ID" />
        <button :disabled="loading.userBreaks">{{ loading.userBreaks ? 'Loading…' : 'Refresh' }}</button>
      </form>
      <pre class="pre" v-if="userBreaks">{{ userBreaks }}</pre>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { chartsApi } from '../api/charts'

const total = ref(null)
const userHours = ref(null)
const userSessions = ref(null)
const userId = ref('')
const userId2 = ref('')
const userId3 = ref('')
const query = ref({})
const query2 = ref({})
const query3 = ref({})

const loading = ref({ total: false, userHours: false, userSessions: false, userBreaks: false })

const loadTotal = async () => {
  loading.value.total = true
  try { total.value = await chartsApi.totalHours(query.value) } finally { loading.value.total = false }
}
const loadUserHours = async () => {
  if (!userId.value) return
  loading.value.userHours = true
  try { userHours.value = await chartsApi.hoursByUser(userId.value, query2.value) } finally { loading.value.userHours = false }
}
const loadUserSessions = async () => {
  if (!userId2.value) return
  loading.value.userSessions = true
  try { userSessions.value = await chartsApi.sessionsByUser(userId2.value, query3.value) } finally { loading.value.userSessions = false }
}
const loadUserBreaks = async () => {
  if (!userId3.value) return
  loading.value.userBreaks = true
  try { userBreaks.value = await chartsApi.breaksByUser(userId3.value) } finally { loading.value.userBreaks = false }
}

onMounted(() => {
  try {
    const u = JSON.parse(localStorage.getItem('currentUser') || 'null')
    if (u?.id) { userId.value = String(u.id); userId2.value = String(u.id); userId3.value = String(u.id) }
  } catch {}
})
</script>

<style scoped>
.card { margin-top: 1rem; padding: 1rem; background: #111827; border: 1px solid #374151; border-radius: 12px; }
.row { display: flex; gap: .5rem; flex-wrap: wrap; margin-bottom: .75rem; align-items: center; }
input { padding: .45rem .6rem; border-radius: 8px; border: 1px solid #374151; background: #0b0f17; color: #e5e7eb; }
button { padding: .5rem .7rem; border-radius: 8px; background: #2563eb; color: white; border: none; font-weight: 600; }
.pre { background: #0b0f17; border: 1px solid #374151; border-radius: 8px; padding: .75rem; overflow: auto; }
</style>
