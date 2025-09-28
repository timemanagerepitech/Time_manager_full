<template>
  <div class="page-transition">
    <h2 class="title">Sign In</h2>

    <!-- Step 1: Choose a user -->
    <div v-if="!selectedUser" class="users-list">
      <p class="hint">Choose your user</p>

      <div v-if="usersLoading" class="loading">Loading users…</div>
      <p v-else-if="usersError" class="error-message">{{ usersError }}</p>
      <template v-else>
        <div v-if="users && users.length" class="user-chips">
          <button
            v-for="(u, idx) in users"
            :key="idx"
            class="user-chip"
            @click="selectUser(u)"
          >
            {{ displayName(u) }}
            <span class="email">{{ u.email }}</span>
          </button>
        </div>
        <p v-else class="hint">No users found.</p>
      </template>

      <p class="link-text">Don't have an account? <a href="#" @click.prevent="$emit('switch-page', 'signup')" class="link-anchor">Sign Up</a></p>
    </div>

    <!-- Step 2: Enter password for the selected user -->
    <form v-else @submit.prevent="handleSignin">
      <div class="selected-user">
        <span class="avatar">{{ initials(selectedUser) }}</span>
        <div class="user-meta">
          <div class="name">{{ displayName(selectedUser) }}</div>
          <div class="email">{{ selectedUser.email }}</div>
        </div>
        <button type="button" class="change-user" @click="selectedUser = null">Change</button>
      </div>
      <div class="input-group">
        <label class="input-label" for="signin_password">Password</label>
        <input class="input-field" type="password" id="signin_password" v-model="signinForm.password" required>
        <p v-if="loginError" class="error-message">{{ loginError }}</p>
      </div>
      <button type="submit" class="submit-button">
        Sign In
      </button>
    </form>
  </div>
</template>

<script>
export default {
  name: 'LoginPage',
  props: {
    users: {
      type: Array,
      default: () => []
    },
    usersLoading: {
      type: Boolean,
      default: false
    },
    usersError: {
      type: String,
      default: ''
    },
    loginError: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      selectedUser: null,
      signinForm: {
        password: ''
      }
    };
  },
  methods: {
    initials(u) {
      const base = (u.username || u.email || '')
      const parts = String(base).split(/[\s._-]+/).filter(Boolean)
      if (parts.length >= 2) return `${parts[0][0] || ''}${parts[1][0] || ''}`.toUpperCase()
      return String(base).slice(0, 2).toUpperCase()
    },
    displayName(u) {
      return u.username || u.email || 'User'
    },
    selectUser(u) {
      this.selectedUser = u
      this.signinForm.password = ''
    },
    handleSignin() {
      if (!this.selectedUser) return
      this.$emit('signin', { email: this.selectedUser.email, password: this.signinForm.password });
    }
  }
};
</script>

<style scoped>
.page-transition {
  transition: opacity 0.5s ease-in-out;
}
.title {
  font-size: 1.875rem;
  font-weight: bold;
  margin-bottom: 1.5rem;
  text-align: center;
  color: #2dd4bf;
}
.input-group {
  margin-bottom: 1rem;
}
.input-label {
  display: block;
  color: #d1d5db;
  font-size: 0.875rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}
.input-field {
  width: 100%;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  background-color: #374151;
  color: #ffffff;
  border: 1px solid #4b5563;
  transition: all 0.3s ease;
}
.input-field:focus {
  border-color: #2dd4bf;
  outline: none;
}
.error-message {
  color: #f87171;
  font-size: 0.75rem;
  margin-top: 0.5rem;
}
.submit-button {
  width: 100%;
  background-color: #10b981;
  color: #ffffff;
  font-weight: bold;
  padding: 0.75rem 1rem;
  border-radius: 0.75rem;
  transition: background-color 0.3s ease;
}
.submit-button:hover {
  background-color: #059669;
}
.link-text {
  margin-top: 1rem;
  text-align: center;
  color: #9ca3af;
}
.link-anchor {
  color: #2dd4bf;
  text-decoration: none;
}
.link-anchor:hover {
  text-decoration: underline;
}

/* Additional styles for user picker */
.users-list { margin-top: 0.5rem; }
.hint { color: #9ca3af; font-size: 0.875rem; }
.loading { color: #d1d5db; }
.user-chips { display: flex; flex-direction: column; gap: 0.5rem; }
.user-chip {
  width: 100%;
  text-align: left;
  background-color: #374151;
  color: #ffffff;
  padding: 0.75rem 1rem;
  border-radius: 0.5rem;
  border: 1px solid #4b5563;
  transition: background-color 0.2s ease;
}
.user-chip:hover { background-color: #4b5563; }
.user-chip .email { display: block; font-size: 0.875rem; color: #d1d5db; }

.selected-user {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  background-color: #1f2937;
  border: 1px solid #374151;
  border-radius: 0.5rem;
  padding: 0.75rem;
  margin-bottom: 1rem;
}
.selected-user .avatar {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 9999px;
  background-color: #14b8a6;
  color: #111827;
  font-weight: 700;
}
.selected-user .user-meta .name { color: #fff; font-weight: 600; }
.selected-user .user-meta .email { color: #d1d5db; font-size: 0.875rem; }
.selected-user .change-user { color: #38bdf8; font-size: 0.875rem; }
.selected-user .change-user:hover { text-decoration: underline; }
</style>
