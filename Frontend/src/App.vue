<template>
  <div id="app">
    <header class="topbar">
      <nav class="nav">
        <RouterLink to="/dashboard">Dashboard</RouterLink>
        <RouterLink to="/working-times">Working Times</RouterLink>
        <RouterLink to="/clockins">Clockins</RouterLink>
        <span class="spacer"/>
        <RouterLink to="/login">Logout</RouterLink>
      </nav>
    </header>
    <main class="content">
      <RouterView />
    </main>
    <ChatBot />
  </div>
</template>

<script setup>
import { RouterLink, RouterView } from 'vue-router';
import ChatBot from '@/components/ChatBot.vue';
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap');

:root { color-scheme: light dark; }
html, body, #app { height: 100%; }
body {
  margin: 0;
  padding: 0;
  background: #0b0f17;
  font-family: 'Inter', system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
  color: #e5e7eb;
}
.topbar {
  position: sticky; top: 0; z-index: 10;
  background: #111827; border-bottom: 1px solid #374151;
}
.nav {
  display: flex; gap: 1rem; align-items: center; padding: .75rem 1rem;
}
.nav a { color: #e5e7eb; text-decoration: none; font-weight: 600; }
.nav a.router-link-active { color: #60a5fa; }
.spacer { flex: 1; }
.content { padding: 1rem; max-width: 1200px; margin: 0 auto; }
</style>
