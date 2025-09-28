<template>
  <div class="chart-card">
    <h3 class="chart-title">Today's Breaks (minutes between sessions)</h3>
    <canvas ref="canvasEl"></canvas>
  </div>
</template>

<script setup>
import { onMounted, onBeforeUnmount, ref, watch } from 'vue'
import Chart from 'https://esm.sh/chart.js@4.4.3/auto'

const props = defineProps({
  breaks: {
    type: Array,
    default: () => [] // [1.5, 3.2, ...] minutes
  },
  reasons: {
    type: Array,
    default: () => [] // ['Lunch', 'Meeting', ...] parallel to breaks
  }
})

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
  const labels = props.breaks.map((_, i) => `B${i + 1}`)

  chartInstance = new Chart(ctx, {
    type: 'bar',
    data: {
      labels,
      datasets: [
        {
          label: 'Break Minutes',
          data: props.breaks,
          backgroundColor: '#F87171'
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
            label: (ctx) => {
              const idx = ctx.dataIndex ?? 0
              const reason = props.reasons[idx] || 'No reason provided'
              return `${ctx.dataset.label}: ${toMinSecLabel(ctx.parsed.y)} — ${reason}`
            }
          }
        }
      }
    }
  })
}

onMounted(buildChart)

onBeforeUnmount(() => { if (chartInstance) chartInstance.destroy() })

watch(() => [props.breaks, props.reasons], () => {
  if (!chartInstance) return
  chartInstance.data.labels = props.breaks.map((_, i) => `B${i + 1}`)
  chartInstance.data.datasets[0].data = props.breaks
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
