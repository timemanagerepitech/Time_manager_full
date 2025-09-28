<template>
  <div class="chart-card">
    <h3 class="chart-title">Today's Sessions (minutes per session)</h3>
    <canvas ref="canvasEl"></canvas>
  </div>
</template>

<script setup>
import { onMounted, onBeforeUnmount, ref, watch } from 'vue'
import Chart from 'https://esm.sh/chart.js@4.4.3/auto'

const props = defineProps({
  sessions: {
    type: Array,
    default: () => [] // [{ duration: '12m 30s' }]
  }
})

const toMinutes = (durationStr) => {
  if (!durationStr) return 0
  const m = /(?:(\d+)m)?\s*(?:(\d+)s)?/.exec(durationStr)
  if (!m) return 0
  const minutes = parseInt(m[1] || '0', 10)
  const seconds = parseInt(m[2] || '0', 10)
  return minutes + seconds / 60
}

const toMinSecLabel = (decimalMinutes) => {
  const totalSeconds = Math.round(decimalMinutes * 60)
  const mins = Math.floor(totalSeconds / 60)
  const secs = totalSeconds % 60
  return `${mins}m ${secs}s`
}

const canvasEl = ref(null)
let chartInstance

const buildChart = () => {
  const ctx = canvasEl.value.getContext('2d')
  const labels = props.sessions.map((_, i) => `S${i + 1}`)
  const values = props.sessions.map((s) => toMinutes(s.duration))

  chartInstance = new Chart(ctx, {
    type: 'bar',
    data: {
      labels,
      datasets: [
        {
          label: 'Minutes',
          data: values,
          backgroundColor: '#34D399'
        }
      ]
    },
    options: {
      responsive: true,
      scales: {
        x: { ticks: { color: '#9CA3AF' }, grid: { color: 'rgba(156,163,175,0.2)' } },
        y: { ticks: { color: '#9CA3AF', stepSize: 0.5 }, grid: { color: 'rgba(156,163,175,0.2)' }, title: { display: true, text: 'Minutes', color: '#E5E7EB' } }
      },
      plugins: {
        legend: { labels: { color: '#E5E7EB' } },
        tooltip: {
          callbacks: {
            label: (ctx) => `${ctx.dataset.label}: ${toMinSecLabel(ctx.parsed.y)}`
          }
        }
      }
    }
  })
}

onMounted(buildChart)

onBeforeUnmount(() => { if (chartInstance) chartInstance.destroy() })

watch(() => props.sessions, () => {
  if (!chartInstance) return
  chartInstance.data.labels = props.sessions.map((_, i) => `S${i + 1}`)
  chartInstance.data.datasets[0].data = props.sessions.map((s) => toMinutes(s.duration))
  chartInstance.update()
}, { deep: true })
</script>

<style scoped>
.chart-card { 
  background: #1f2937; 
  border: 1px solid #374151; 
  border-radius: 0.75rem; 
  padding: 1rem; 
  margin-top: 1rem;
}
.chart-title { 
  color: #E5E7EB; 
  font-weight: 600; 
  font-size: 0.95rem; 
  margin-bottom: 0.5rem;
}
</style>
