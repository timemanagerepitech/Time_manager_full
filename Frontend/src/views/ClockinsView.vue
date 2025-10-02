<template>
  <section>
    <h1>Clock in/out</h1>
    <div class="card">
      <form class="row" @submit.prevent="toggle">
        <button :disabled="creating">{{ creating ? 'Toggling…' : 'Toggle Clock' }}</button>
        <button type="button" @click="load">Refresh</button>
      </form>

      <div class="timer" v-if="runningSince">
        <span>Active session:</span>
        <strong>{{ fmtHMS(liveSeconds) }}</strong>
        <span class="sub">since {{ fmtIso(runningSince) }}</span>
      </div>

      <p v-if="loading">Loading…</p>
      <p v-if="error" class="error">{{ error }}</p>

      <table v-if="!loading" class="table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Time</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="c in list" :key="c.id">
            <td>{{ c.id }}</td>
            <td>{{ fmtIso(c.time) }}</td>
            <td>{{ c.status ? 'In' : 'Out' }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="card">
      <h2>Working time by day</h2>
      <div class="row" style="margin-bottom:.5rem">
        <label>Filter date: <input type="date" v-model="chartsDate" @change="loadCharts" /></label>
      </div>
      <p v-if="chartsLoading">Loading charts…</p>
      <div v-else>
        <div v-if="hoursRows.length === 0" class="hint">No working time yet.</div>
        <template v-else>
          <table class="table">
            <thead>
              <tr><th>Date</th><th>Minutes</th><th>mm:ss</th><th>Hours</th></tr>
            </thead>
            <tbody>
              <tr v-for="r in hoursRows" :key="r.date">
                <td>{{ r.date }}</td>
                <td>{{ (r.seconds ? (r.seconds/60).toFixed(2) : r.minutes) }}</td>
                <td>{{ fmtMMSS(r.seconds ?? (r.minutes * 60)) }}</td>
                <td>{{ r.hours }}</td>
              </tr>
            </tbody>
          </table>
          <div class="chart-box" v-if="hoursRows.length > 1">
            <canvas ref="hoursCanvas" height="100"></canvas>
          </div>
        </template>
      </div>
    </div>

    <div class="card">
      <h2>Breaks</h2>
      <div v-if="breaks.length === 0" class="hint">No data yet.</div>
      <template v-else>
        <table class="table">
          <thead>
            <tr><th>Start</th><th>End</th><th>Minutes</th><th>mm:ss</th></tr>
          </thead>
          <tbody>
            <tr v-for="(b, i) in breaks" :key="i">
              <td>{{ fmtIso(b.start) }}</td>
              <td>{{ fmtIso(b.end) }}</td>
              <td>{{ (b.seconds ? (b.seconds/60).toFixed(2) : b.minutes) }}</td>
              <td>{{ fmtMMSS(b.seconds ?? (b.minutes * 60)) }}</td>
            </tr>
          </tbody>
        </table>
        <div class="chart-box">
          <canvas ref="breaksCanvas" height="120"></canvas>
        </div>
      </template>
    </div>

    <div class="card">
      <h2>Working sessions</h2>
      <div v-if="sessions.length === 0" class="hint">No data yet.</div>
      <template v-else>
        <table class="table">
          <thead>
          <tr><th>Start</th><th>End</th><th>Minutes</th><th>mm:ss</th></tr>
        </thead>
        <tbody>
          <tr v-for="(s, i) in sessions" :key="i">
            <td>{{ fmtIso(s.start) }}</td>
            <td>{{ fmtIso(s.end) }}</td>
            <td>{{ (s.seconds ? (s.seconds/60).toFixed(2) : s.minutes) }}</td>
            <td>{{ fmtMMSS(s.seconds ?? (s.minutes * 60)) }}</td>
          </tr>
        </tbody>
        </table>
        <div class="chart-box">
          <canvas ref="sessionsCanvas" height="120"></canvas>
        </div>
      </template>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { clockinsApi } from '../api/clockins'
import { chartsApi } from '../api/charts'
import Chart from 'chart.js/auto'

const list = ref([])
const loading = ref(false)
const error = ref('')
const creating = ref(false)
const currentUserId = ref('')
const chartsDate = ref('')
const chartsLoading = ref(false)
const hoursRows = ref([])
const breaks = ref([])
const sessions = ref([])
const hoursCanvas = ref(null)
const breaksCanvas = ref(null)
const sessionsCanvas = ref(null)
let hoursChart = null
let breaksChart = null
let sessionsChart = null
const runningSince = ref(null)
const liveSeconds = ref(0)
let timer = null

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

const fmtHMS = (totalSeconds) => {
  const sec = Math.max(0, Math.floor(Number(totalSeconds) || 0))
  const h = Math.floor(sec / 3600)
  const m = Math.floor((sec % 3600) / 60)
  const s = sec % 60
  return `${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}:${String(s).padStart(2,'0')}`
}

const startTimer = (fromIso) => {
  stopTimer()
  runningSince.value = fromIso
  const from = Date.parse(fromIso)
  timer = setInterval(() => { liveSeconds.value = Math.max(0, Math.floor((Date.now() - from) / 1000)) }, 1000)
}

const stopTimer = () => {
  if (timer) clearInterval(timer)
  timer = null
  runningSince.value = null
  liveSeconds.value = 0
}

const load = async () => {
  loading.value = true
  error.value = ''
  try {
    if (!currentUserId.value) { list.value = []; return }
    const res = await clockinsApi.listByUser(currentUserId.value)
    list.value = Array.isArray(res?.data) ? res.data : (Array.isArray(res) ? res : [])
    const last = list.value[0]
    if (last?.status) {
      startTimer(last.time)
    } else {
      stopTimer()
    }
  } catch (_) {
    error.value = 'Failed to load clockins'
  } finally {
    loading.value = false
  }
}

const loadCharts = async () => {
  if (!currentUserId.value) { hoursRows.value = []; breaks.value = []; return }
  chartsLoading.value = true
  try {
    const hoursRes = await chartsApi.hoursByUser(currentUserId.value, chartsDate.value ? { date: chartsDate.value } : undefined)
    const hoursData = Array.isArray(hoursRes?.data) ? hoursRes.data : []
    hoursRows.value = hoursData

    const breaksRes = await chartsApi.breaksByUser(currentUserId.value, chartsDate.value ? { date: chartsDate.value } : undefined)
    breaks.value = Array.isArray(breaksRes?.data) ? breaksRes.data : []

    const sessRes = await chartsApi.sessionsByUser(currentUserId.value)
    sessions.value = Array.isArray(sessRes?.data) ? sessRes.data : []
    updateCharts()
  } finally {
    chartsLoading.value = false
  }
}

const updateCharts = () => {
  // Hours by day (mm:ss)
  const labels = hoursRows.value.map(r => r.date)
  const seconds = hoursRows.value.map(r => r.seconds || (r.minutes * 60))
  if (hoursChart) hoursChart.destroy()
  if (hoursCanvas.value) {
    hoursChart = new Chart(hoursCanvas.value.getContext('2d'), {
      type: 'line',
      data: { 
        labels, 
        datasets: [{ 
          label: 'Working Time', 
          data: seconds, 
          borderColor: '#60a5fa', 
          backgroundColor: 'rgba(96,165,250,0.2)', 
          tension: 0.3 
        }] 
      },
      options: { 
        responsive: true, 
        maintainAspectRatio: false,
        scales: {
          y: {
            ticks: {
              callback: function(value) {
                return fmtMMSS(value);
              }
            }
          }
        },
        plugins: { 
          tooltip: { 
            callbacks: { 
              label: (ctx) => ` ${fmtMMSS(ctx.parsed.y)}`
            } 
          } 
        } 
      }
    })
  }

  // Breaks durations over time (mm:ss) using start time label
  const bLabels = breaks.value.map(b => new Date(b.start).toLocaleTimeString())
  const bSeconds = breaks.value.map(b => b.seconds || (b.minutes * 60))
  if (breaksChart) breaksChart.destroy()
  if (breaksCanvas.value) {
    breaksChart = new Chart(breaksCanvas.value.getContext('2d'), {
      type: 'line',
      data: { 
        labels: bLabels, 
        datasets: [{ 
          label: 'Break Duration', 
          data: bSeconds, 
          borderColor: '#f87171', 
          backgroundColor: 'rgba(248,113,113,0.2)', 
          tension: 0.3 
        }] 
      },
      options: { 
        responsive: true, 
        maintainAspectRatio: false,
        scales: {
          y: {
            ticks: {
              callback: function(value) {
                return fmtMMSS(value);
              }
            }
          }
        },
        plugins: { 
          tooltip: { 
            callbacks: { 
              label: (ctx) => ` ${fmtMMSS(ctx.parsed.y)}`
            } 
          } 
        } 
      }
    })
  }

  // Working sessions durations over time (mm:ss) using start time label
  const sLabels = sessions.value.map(s => new Date(s.start).toLocaleTimeString())
  const sSeconds = sessions.value.map(s => s.seconds || (s.minutes * 60))
  if (sessionsChart) sessionsChart.destroy()
  if (sessionsCanvas.value) {
    sessionsChart = new Chart(sessionsCanvas.value.getContext('2d'), {
      type: 'line',
      data: { 
        labels: sLabels, 
        datasets: [{ 
          label: 'Session Duration', 
          data: sSeconds, 
          borderColor: '#34d399', 
          backgroundColor: 'rgba(52,211,153,0.2)', 
          tension: 0.3 
        }] 
      },
      options: { 
        responsive: true, 
        maintainAspectRatio: false,
        scales: {
          y: {
            ticks: {
              callback: function(value) {
                return fmtMMSS(value);
              }
            }
          }
        },
        plugins: { 
          tooltip: { 
            callbacks: { 
              label: (ctx) => ` ${fmtMMSS(ctx.parsed.y)}`
            } 
          } 
        } 
      }
    })
  }
}

const toggle = async () => {
  creating.value = true
  try {
    if (!currentUserId.value) return
    await clockinsApi.toggleForUser(currentUserId.value)
    await load()
    await loadCharts()
  } finally {
    creating.value = false
  }
}

onMounted(() => {
  try {
    const u = JSON.parse(localStorage.getItem('currentUser') || 'null')
    if (u?.id) currentUserId.value = String(u.id)
  } catch {}
  // default charts date to today (YYYY-MM-DD)
  const today = new Date()
  const yyyy = today.getFullYear()
  const mm = String(today.getMonth() + 1).padStart(2, '0')
  const dd = String(today.getDate()).padStart(2, '0')
  chartsDate.value = `${yyyy}-${mm}-${dd}`
  load()
  loadCharts()
})
</script>

<style scoped>
.card { margin-top: 1rem; padding: 1rem; background: #111827; border: 1px solid #374151; border-radius: 12px; }
.table { width: 100%; border-collapse: collapse; }
th, td { text-align: left; padding: .5rem; border-bottom: 1px solid #374151; }
.error { color: #ef4444; }
.row { display: flex; gap: .5rem; flex-wrap: wrap; margin-bottom: .75rem; align-items: center; }
input { padding: .45rem .6rem; border-radius: 8px; border: 1px solid #374151; background: #0b0f17; color: #e5e7eb; }
button { padding: .5rem .7rem; border-radius: 8px; background: #2563eb; color: white; border: none; font-weight: 600; margin-right: .5rem; }
.hint { color: #9ca3af; }
.chart-box { position: relative; height: 180px; margin-top: .5rem; }
</style>

