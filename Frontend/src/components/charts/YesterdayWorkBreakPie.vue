<template>
  <div class="chart-card">
    <h3 class="chart-title">Yesterday: Work vs Break</h3>
    <canvas ref="canvasEl"></canvas>
  </div>
</template>

<script setup>
import { onMounted, onBeforeUnmount, ref, watch } from 'vue'
// Use ESM CDN for Chart.js auto bundle (works without local npm dependency)
import Chart from 'https://esm.sh/chart.js@4.4.3/auto'

const props = defineProps({
  workMinutes: { type: Number, default: 0 },
  breakMinutes: { type: Number, default: 0 }
})

const canvasEl = ref(null)
let chartInstance

const buildChart = () => {
  const ctx = canvasEl.value.getContext('2d')
  const data = {
    labels: ['Work', 'Break'],
    datasets: [
      {
        label: 'Minutes',
        data: [props.workMinutes, props.breakMinutes],
        backgroundColor: ['#10B981', '#EF4444'], // green, red
        borderColor: ['#059669', '#DC2626'],
        borderWidth: 1
      }
    ]
  }
  const options = {
    responsive: true,
    plugins: {
      legend: {
        labels: { color: '#E5E7EB' }
      },
      tooltip: {
        callbacks: {
          label: (ctx) => `${ctx.label}: ${ctx.raw} min`
        }
      }
    }
  }
  chartInstance = new Chart(ctx, { type: 'pie', data, options })
}

onMounted(() => buildChart())

onBeforeUnmount(() => {
  if (chartInstance) chartInstance.destroy()
})

watch(() => [props.workMinutes, props.breakMinutes], () => {
  if (!chartInstance) return
  chartInstance.data.datasets[0].data = [props.workMinutes, props.breakMinutes]
  chartInstance.update()
})
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
