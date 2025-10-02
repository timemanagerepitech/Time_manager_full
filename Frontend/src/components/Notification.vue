<template>
  <transition name="fade">
    <div v-if="isVisible" :class="['notification', type]">
      <div class="notification-content">
        <span class="icon">
          <svg v-if="type === 'success'" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
            <polyline points="22 4 12 14.01 9 11.01"></polyline>
          </svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="8" x2="12" y2="12"></line>
            <line x1="12" y1="16" x2="12.01" y2="16"></line>
          </svg>
        </span>
        <div class="message">{{ message }}</div>
        <button class="close-btn" @click="hide" aria-label="Close notification">
          &times;
        </button>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({
  message: {
    type: String,
    required: true
  },
  type: {
    type: String,
    default: 'info',
    validator: (value) => ['success', 'error', 'info', 'warning'].includes(value)
  },
  duration: {
    type: Number,
    default: 3000
  }
})

const isVisible = ref(false)
let timeoutId = null

const show = () => {
  isVisible.value = true
  if (props.duration > 0) {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(hide, props.duration)
  }
}

const hide = () => {
  isVisible.value = false
  clearTimeout(timeoutId)
}

defineExpose({
  show,
  hide
})

onMounted(() => {
  show()
})
</script>

<style scoped>
.notification {
  position: fixed;
  top: 1rem;
  right: 1rem;
  z-index: 1000;
  min-width: 300px;
  max-width: 90vw;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  overflow: hidden;
  transition: all 0.3s ease;
  transform: translateX(0);
  opacity: 1;
}

.notification.success {
  background-color: #10b981;
  color: white;
}

.notification.error {
  background-color: #ef4444;
  color: white;
}

.notification.info {
  background-color: #3b82f6;
  color: white;
}

.notification.warning {
  background-color: #f59e0b;
  color: white;
}

.notification-content {
  display: flex;
  align-items: center;
  padding: 1rem;
  gap: 0.75rem;
}

.icon {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  width: 24px;
  height: 24px;
}

.message {
  flex-grow: 1;
  font-size: 0.9375rem;
  line-height: 1.5;
}

.close-btn {
  background: none;
  border: none;
  color: inherit;
  cursor: pointer;
  font-size: 1.5rem;
  line-height: 1;
  opacity: 0.8;
  padding: 0.25rem;
  margin-left: 0.5rem;
  transition: opacity 0.2s;
}

.close-btn:hover {
  opacity: 1;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(-20px);
}
</style>
