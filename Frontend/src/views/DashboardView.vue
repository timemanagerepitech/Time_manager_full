<template>
  <section>
    <div class="header">
      <div>
        <h1>Dashboard</h1>
        <p v-if="user" class="muted">Welcome, <b>{{ user.username || [user.first_name, user.last_name].filter(Boolean).join(' ') }}</b></p>
      </div>
      <div class="badges">
        <span class="badge">
          <span class="k">Work</span>
          <span class="v">{{ totalWorkMin }}m ({{ totalWorkMin * 60 }}s)</span>
        </span>
        <span class="badge warn">
          <span class="k">Break</span>
          <span class="v">{{ totalBreakMin }}m ({{ totalBreakMin * 60 }}s)</span>
        </span>
        <span class="badge info">
          <span class="k">Sessions</span>
          <span class="v">{{ allSessions.length }}</span>
        </span>
      </div>
      <button class="ghost" @click="openProfile">Edit Profile</button>
    </div>

    <div class="card">
      <h2>Today's Sessions</h2>
      <p v-if="loading">Loading…</p>
      <p v-if="error" class="error">{{ error }}</p>
      <div v-if="!loading && sessions.length === 0">No sessions recorded today.</div>
      <table v-if="!loading && sessions.length" class="table">
        <thead>
          <tr>
            <th>Start</th>
            <th>End</th>
            <th>Duration</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(s, i) in sessions" :key="i">
            <td>{{ s.start }}</td>
            <td>{{ s.end }}</td>
            <td>{{ s.duration }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="card">
      <h2>Working Time (Line)</h2>
      <div v-if="hoursRows.length === 0" class="hint">No working time yet.</div>
      <template v-else>
        <table class="table">
          <thead>
            <tr><th>Date</th><th>Minutes</th><th>mm:ss</th><th>Hours</th></tr>
          </thead>
          <tbody>
            <tr v-for="r in hoursRows" :key="r.date">
              <td>{{ r.date }}</td>
              <td>{{ (r.seconds / 60).toFixed(2) }}</td>
              <td>{{ fmtMMSS(r.seconds) }}</td>
              <td>{{ r.hours }}</td>
            </tr>
          </tbody>
        </table>
        <div class="chart-box"><canvas ref="hoursCanvas" height="120"></canvas></div>
      </template>
    </div>

    <div class="card">
      <h2>Breaks vs Work (Doughnut)</h2>
      <div class="chart-box"><canvas ref="pieCanvas" height="120"></canvas></div>
      <div class="hint">Breaks and total session minutes from your history.</div>
    </div>

    <div class="card">
      <h2>Working Sessions (Scatter)</h2>
      <div v-if="allSessions.length === 0" class="hint">No sessions yet.</div>
      <div v-else class="chart-box"><canvas ref="scatterCanvas" height="120"></canvas></div>
    </div>
  </section>
  
  <!-- Edit Profile Modal -->
  <div v-if="showProfile" class="modal-backdrop" @click.self="showProfile=false">
    <div class="modal">
      <h3>Edit profile</h3>
      <div class="form">
        <label>
          Username
          <input v-model.trim="profile.username" type="text" />
        </label>
        <label>
          First name
          <input v-model.trim="profile.first_name" type="text" />
        </label>
        <label>
          Last name
          <input v-model.trim="profile.last_name" type="text" />
        </label>
      </div>
      <div class="actions">
        <button class="ghost" @click="showProfile=false">Cancel</button>
        <button @click="saveProfile">Save</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { workingTimesApi } from '../api/workingTimes'
import { usersApi } from '../api/users'
import { chartsApi } from '../api/charts'
import Chart from 'chart.js/auto'

const user = ref(null)
const loading = ref(false)
const error = ref('')
const sessions = ref([])
const hoursRows = ref([])
const allSessions = ref([])
const totalWorkMin = ref(0)
const totalBreakMin = ref(0)
const hoursCanvas = ref(null)
const pieCanvas = ref(null)
const scatterCanvas = ref(null)
let hoursChart = null
let pieChart = null
let scatterChart = null

// Edit profile modal state
const showProfile = ref(false)
const profile = ref({ username: '', first_name: '', last_name: '' })

const loadToday = async () => {
  if (!user.value?.id) return
  loading.value = true
  error.value = ''
  try {
    const data = await workingTimesApi.list(user.value.id)
    const list = Array.isArray(data) ? data : (Array.isArray(data?.data) ? data.data : [])

    // Build today's local date components
    const now = new Date()
    const y = now.getFullYear()
    const m = now.getMonth()
    const d = now.getDate()
    const isTodayLocal = (iso) => {
      if (!iso) return false
      const t = new Date(iso)
      return t.getFullYear() === y && t.getMonth() === m && t.getDate() === d
    }

    const todays = list.filter(w => isTodayLocal(w.start || w.start_time || w.startTime))

    sessions.value = todays.map(w => {
      const startIso = w.start || w.start_time || w.startTime
      const endIso = w.end || w.end_time || w.endTime
      const startTs = startIso ? Date.parse(startIso) : null
      const endTs = endIso ? Date.parse(endIso) : null
      const durSec = startTs && endTs ? Math.max(0, Math.floor((endTs - startTs) / 1000)) : 0
      const minutes = Math.floor(durSec / 60)
      const seconds = durSec % 60
      const fmt = (ts) => ts ? new Date(ts).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '--:--'
      return { start: fmt(startTs), end: fmt(endTs), duration: `${minutes}m ${String(seconds).padStart(2,'0')}s` }
    })
  } catch (_) {
    error.value = 'Failed to load today\'s sessions'
  } finally {
    loading.value = false
  }
}

const fmtIso = (iso) => {
  if (!iso) return '--'
  const d = new Date(iso)
  if (isNaN(+d)) return String(iso)
  return d.toLocaleString()
}

const fmtMMSS = (totalSeconds) => {
  const sec = Math.max(0, Math.floor(Number(totalSeconds) || 0))
  const m = Math.floor(sec / 60)
  const s = sec % 60
  return `${m}:${String(s).padStart(2, '0')}`
}

const secondsBetween = (startIso, endIso) => {
  const a = startIso ? Date.parse(startIso) : NaN
  const b = endIso ? Date.parse(endIso) : NaN
  if (Number.isNaN(a) || Number.isNaN(b)) return 0
  return Math.max(0, Math.floor((b - a) / 1000))
}

const loadCharts = async () => {
  if (!user.value?.id) return
  // Hours by day
  const hoursRes = await chartsApi.hoursByUser(user.value.id)
  hoursRows.value = Array.isArray(hoursRes?.data) ? hoursRes.data : []

  // Sessions list (for scatter)
  const sessRes = await chartsApi.sessionsByUser(user.value.id)
  allSessions.value = Array.isArray(sessRes?.data) ? sessRes.data : []

  // Breaks list
  const breaksRes = await chartsApi.breaksByUser(user.value.id)
  const breaks = Array.isArray(breaksRes?.data) ? breaksRes.data : []

  // Compute totals for badges
  totalWorkMin.value = hoursRows.value.reduce((a, r) => a + (r.minutes || 0), 0)
  totalBreakMin.value = breaks.reduce((a, b) => a + (b.minutes || 0), 0)

  updateCharts(breaks)
}

const updateCharts = (breaks) => {
  // Bar chart for hours by day (minutes)
  const labels = hoursRows.value.map(r => r.date)
  const minutes = hoursRows.value.map(r => r.minutes)
  if (hoursChart) hoursChart.destroy()
  if (hoursCanvas.value) {
    hoursChart = new Chart(hoursCanvas.value.getContext('2d'), {
      type: 'bar',
      data: { labels, datasets: [{ label: 'Minutes Worked', data: minutes, borderColor: '#60a5fa', backgroundColor: 'rgba(96,165,250,0.5)' }] },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          tooltip: { callbacks: { label: (ctx) => ` ${ctx.parsed.y}m (${fmtMMSS(ctx.parsed.y * 60)})` } },
          legend: { position: 'bottom' }
        },
        scales: { y: { beginAtZero: true, ticks: { callback: v => `${v}m` } } }
      }
    })
  }

  // Pie chart: Work vs Break (minutes)
  const totalWorkMin = minutes.reduce((a,b)=>a+b,0)
  const totalBreakMin = breaks.reduce((a,b)=>a + (b.minutes||0), 0)
  if (pieChart) pieChart.destroy()
  if (pieCanvas.value) {
    pieChart = new Chart(pieCanvas.value.getContext('2d'), {
      type: 'doughnut',
      data: { labels: ['Work', 'Break'], datasets: [{ data: [totalWorkMin, totalBreakMin], backgroundColor: ['#34d399','#f87171'], borderWidth: 0 }] },
      options: {
        cutout: '60%',
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'bottom' },
          tooltip: { callbacks: { label: (ctx) => ` ${ctx.formattedValue}m (${fmtMMSS(ctx.parsed * 60)})` } }
        }
      }
    })
  }

  // Scatter chart: each session (x = start time index, y = minutes)
  const points = allSessions.value.map((s, i) => ({ x: i + 1, y: s.minutes }))
  if (scatterChart) scatterChart.destroy()
  if (scatterCanvas.value) {
    scatterChart = new Chart(scatterCanvas.value.getContext('2d'), {
      type: 'scatter',
      data: { datasets: [{ label: 'Session Minutes', data: points, backgroundColor: '#93c5fd' }] },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { tooltip: { callbacks: { label: (ctx) => ` ${ctx.raw.y}m (${fmtMMSS(ctx.raw.y * 60)})` } }, legend: { display: false } },
        scales: { x: { title: { display: true, text: 'Session #' } }, y: { beginAtZero: true, title: { display: true, text: 'Minutes' } } }
      }
    })
  }
}

onMounted(() => {
  try { user.value = JSON.parse(localStorage.getItem('currentUser') || 'null') } catch { user.value = null }
  if (user.value) profile.value = { username: user.value.username || '', first_name: user.value.first_name || '', last_name: user.value.last_name || '' }
  loadToday()
  loadCharts()
})

const openProfile = () => {
  if (!user.value) return
  profile.value = { username: user.value.username || '', first_name: user.value.first_name || '', last_name: user.value.last_name || '' }
  showProfile.value = true
}

const saveProfile = async () => {
  if (!user.value) return
  try {
    const res = await usersApi.update(user.value.id, {
      username: profile.value.username,
      first_name: profile.value.first_name,
      last_name: profile.value.last_name,
    })
    const updated = res?.data || res
    user.value = updated
    localStorage.setItem('currentUser', JSON.stringify(user.value))
    showProfile.value = false
  } catch (e) {
    console.error('Failed to update profile', e)
    alert('Failed to save profile. Ensure backend is running and migration applied.')
  }
}
</script>

<style scoped>
.header { display: flex; justify-content: space-between; align-items: flex-end; gap: 1rem; margin-bottom: .5rem; }
.muted { color: #9ca3af; }
.badges { display: flex; gap: .5rem; flex-wrap: wrap; }
.badge { background: #0b0f17; border: 1px solid #1f2937; color: #e5e7eb; padding: .5rem .65rem; border-radius: 10px; display: inline-flex; gap: .5rem; align-items: baseline; }
.badge .k { color: #9ca3af; font-size: .85rem; }
.badge .v { font-weight: 700; }
.badge.warn { background: rgba(248,113,113,0.1); border-color: #4b1f22; }
.badge.info { background: rgba(96,165,250,0.1); border-color: #1e3a5f; }
.card { margin-top: 1rem; padding: 1rem; background: #111827; border: 1px solid #374151; border-radius: 12px; }
.table { width: 100%; border-collapse: collapse; }
th, td { text-align: left; padding: .5rem; border-bottom: 1px solid #374151; }
.error { color: #ef4444; }
.hint { color: #9ca3af; }
.chart-box { position: relative; height: 260px; margin-top: .75rem; }
.ghost { background: transparent; border: 1px solid #374151; color: #e5e7eb; padding: .45rem .7rem; border-radius: 8px; }
.modal-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 50; }
.modal { width: 100%; max-width: 420px; background: #111827; border: 1px solid #374151; border-radius: 12px; padding: 1rem; }
.modal h3 { margin: 0 0 .75rem 0; }
.modal .form { display: flex; gap: .75rem; flex-direction: column; }
.modal input { width: 100%; padding: .5rem .6rem; border-radius: 8px; border: 1px solid #374151; background: #0b0f17; color: #e5e7eb; }
.modal .actions { display: flex; gap: .5rem; justify-content: flex-end; margin-top: 1rem; }
</style>
