<template>
  <div class="app-container">
    <div class="main-card">
      <!-- Loading Overlay -->
      <div v-if="isLoading" class="loader-overlay">
        <div class="loader-spinner"></div>
      </div>

      <LoginPage
        v-if="currentPage === 'signin'"
        :users="users"
        :users-loading="usersLoading"
        :users-error="usersError"
        @signin="handleSignin"
        @switch-page="currentPage = $event"
        :login-error="loginError"
      />
      <SignupPage v-if="currentPage === 'signup'" @signup="handleSignup" @switch-page="currentPage = $event" />
      
      <EditProfilePage 
        v-if="currentPage === 'editProfile'" 
        :user="loggedInUser"
        @update-profile="handleUpdateProfile"
        @delete-account="handleDeleteAccount"
        @cancel="currentPage = 'homepage'"
      />

      <!-- User Homepage -->
      <div v-if="currentPage === 'homepage'" class="page-transition homepage-layout">
        <div class="homepage-header">
          <div class="profile-name-container">
            <h2 class="user-name">
              {{ loggedInUser.first_name }} {{ loggedInUser.last_name }}
            </h2>
            <span class="profile-name">{{ loggedInUser.profile_name }}</span>
          </div>
          <div class="button-group">
            <button @click="handleEditProfile" class="edit-button">
              Edit Profile
            </button>
            <button @click="handleLogout" class="logout-button">
              Log Out
            </button>
          </div>
        </div>
        
        <div class="main-content-area">
          <!-- Left Column -->
          <div class="left-column">
            <div class="profile-image-container">
              <img src="https://placehold.co/96x96/6ee7b7/111827?text=U" alt="Profile Picture" class="profile-image">
            </div>
            
            <div class="date-display">{{ currentDateDisplay }}</div>
            
            <div class="timer-section">
              <p v-if="isCheckedIn" class="timer-label">Time tracked today:</p>
              <p v-else class="timer-label">Total time tracked today:</p>
              <div class="timer-display">{{ formattedTime }}</div>
            </div>

            <!-- Remaining Working Time -->
            <div class="remaining-section">
              <p class="timer-label">Remaining working time:</p>
              <div class="timer-display">{{ formattedRemaining }}</div>
              <div class="remaining-actions">
                <button class="startwork-button" @click="startRemainingTimer">Start Work</button>
                <button class="endwork-button" @click="stopRemainingTimer">End Work</button>
              </div>
            </div>

            <button @click="toggleCheckIn" :class="isCheckedIn ? 'checkout-button' : 'checkin-button'">
              {{ checkInButtonText }}
            </button>
            <p v-if="clockError" class="error-message">{{ clockError }}</p>

            <!-- Working Time Schedule (Today) -->
            <div class="schedule-card">
              <div class="schedule-row">
                <label class="input-label">Start</label>
                <input class="input-field" type="time" v-model="scheduleStart" />
              </div>
              <div class="schedule-row">
                <label class="input-label">End</label>
                <input class="input-field" type="time" v-model="scheduleEnd" />
              </div>
              <button class="save-schedule-button" :disabled="scheduleSaving" @click="saveScheduleForToday">
                {{ scheduleSaving ? 'Saving…' : 'Save Schedule' }}
              </button>
              <p v-if="scheduleError" class="error-message">{{ scheduleError }}</p>
            </div>

            <!-- Yesterday work vs break pie chart -->
            <YesterdayWorkBreakPie
              :work-minutes="yesterdayWorkMinutes"
              :break-minutes="yesterdayBreakMinutes"
            />

            <!-- Checkout reason input -->
            <div v-if="showCheckoutReason" class="checkout-reason-card">
              <label class="reason-label">Reason for checkout</label>
              <input
                v-model="checkoutReason"
                class="reason-input"
                type="text"
                placeholder="e.g., Lunch break, meeting, end of day"
              />
              <div class="reason-actions">
                <button @click="confirmCheckout" class="confirm-reason">Save & Checkout</button>
                <button @click="cancelCheckout" class="cancel-reason">Cancel</button>
              </div>
            </div>

            <!-- Yesterday work vs break pie chart -->
            <YesterdayWorkBreakPie
              :work-minutes="yesterdayWorkMinutes"
              :break-minutes="yesterdayBreakMinutes"
            />
          </div>
          
          <!-- Right Column -->
          <div class="right-column">
            <div class="sessions-list-container">
                <p class="sessions-title">Today's Sessions:</p>
                <div v-if="workSessions.length > 0" class="sessions-table">
                  <div class="table-header">
                    <span>Start Time</span>
                    <span>End Time</span>
                    <span>Duration</span>
                  </div>
                    <div v-for="(session, index) in workSessions" :key="index" class="session-entry">
                        <span>{{ session.checkInTime }}</span>
                        <span>{{ session.checkOutTime }}</span>
                        <span>{{ session.duration }}</span>
                    </div>
                </div>
                <span v-else class="no-sessions">No sessions recorded today.</span>

                <!-- Charts under the sessions table -->
                <TodaySessionsBar :sessions="workSessions" />
                <TodayBreaksBar :breaks="breaksMinutes" :reasons="breaksReasons" />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import LoginPage from './loginPage.vue';
import SignupPage from './signupPage.vue';
import EditProfilePage from './editProfilePage.vue';
import YesterdayWorkBreakPie from './charts/YesterdayWorkBreakPie.vue';
import TodaySessionsBar from './charts/TodaySessionsBar.vue';
import TodayBreaksBar from './charts/TodayBreaksBar.vue';
import { usersApi } from '../api/users.js';
import { workingTimesApi } from '../api/workingTimes.js';
import { clockinsApi } from '../api/clockins.js';

export default {
  name: 'userManagementApp',
  components: {
    LoginPage,
    SignupPage,
    EditProfilePage,
    YesterdayWorkBreakPie,
    TodaySessionsBar,
    TodayBreaksBar
  },
  data() {
    return {
      currentPage: 'signin',
      users: [],
      usersError: '',
      usersLoading: false,
      loggedInUser: null,
      loginError: '',
      isLoading: false,
      sessionsLoading: false,
      sessionsError: '',
      
      // Timer state
      isCheckedIn: false,
      checkInTime: null,
      checkOutTime: null,
      workSessions: [],
      elapsedTime: 0,
      intervalId: null,
      lastDate: null,
      // Demo values for yesterday's work/break in minutes
      // TODO: Replace with real persisted data when available
      yesterdayWorkMinutes: 300,
      yesterdayBreakMinutes: 120,
      // Checkout reason flow
      showCheckoutReason: false,
      checkoutReason: '',

      // Backend tracking IDs
      // currentWorkingTimeId is now the SCHEDULE for today (not created by check-in)
      currentWorkingTimeId: null,
      currentClockinId: null,

      // Schedule for today (HH:MM) and management
      scheduleStart: '09:00',
      scheduleEnd: '17:00',
      scheduleSaving: false,
      scheduleError: '',
      clockError: '',

      // Remaining working time countdown
      remainingSeconds: 0,
      remainingRunning: false,
      remainingIntervalId: null,
    };
  },
  computed: {
    checkInButtonText() {
      return this.isCheckedIn ? 'Check Out' : 'Check In';
    },
    formattedRemaining() {
      const total = Math.max(0, this.remainingSeconds);
      const hours = Math.floor(total / 3600);
      const minutes = Math.floor((total % 3600) / 60);
      const seconds = total % 60;
      const pad = (n) => String(n).padStart(2, '0');
      return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
    },
    currentDateDisplay() {
        return new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
    },
    formattedTime() {
      const totalSeconds = this.elapsedTime;
      const hours = Math.floor(totalSeconds / 3600);
      const minutes = Math.floor((totalSeconds % 3600) / 60);
      const seconds = totalSeconds % 60;

      const pad = (num) => String(num).padStart(2, '0');
      return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
    },
    // Compute breaks between sessions in minutes
    breaksMinutes() {
      const breaks = [];
      for (let i = 0; i < this.workSessions.length - 1; i++) {
        const current = this.workSessions[i];
        const next = this.workSessions[i + 1];
        if (current.endTs && next.startTs) {
          const gapMs = next.startTs - current.endTs;
          if (gapMs > 0) breaks.push(gapMs / 60000);
        }
      }
      return breaks;
    },
    // The reason associated with each break is the reason for the previous session's checkout
    breaksReasons() {
      const reasons = [];
      for (let i = 0; i < this.workSessions.length - 1; i++) {
        const current = this.workSessions[i];
        reasons.push(current.reason || '');
      }
      return reasons;
    }
  },
  methods: {
    // Extract id from multiple possible API response shapes
    getEntityId(obj) {
      if (!obj) return null;
      if (typeof obj === 'number') return obj;
      if (obj.id) return obj.id;
      if (obj.data?.id) return obj.data.id;
      if (obj.clockin?.id) return obj.clockin.id;
      if (obj.working_time?.id) return obj.working_time.id;
      return null;
    },
    // Load today's sessions for the logged in user from backend working_times
    async loadTodaySessions() {
      if (!this.loggedInUser?.id) return;
      try {
        this.sessionsLoading = true;
        this.sessionsError = '';
        const res = await workingTimesApi.list();
        const list = Array.isArray(res) ? res : (Array.isArray(res?.data) ? res.data : []);
        const userId = this.loggedInUser.id;
        const todayStr = new Date().toISOString().slice(0, 10); // YYYY-MM-DD
        // Filter to today's records for the user
        const todays = list
          .filter((w) => (w.user_id === userId || w.userId === userId))
          .filter((w) => {
            const start = w.start_time || w.startTime || w.start;
            return !!start && String(start).slice(0, 10) === todayStr;
          });

        // Derive today's schedule (use the first working_time as schedule)
        if (todays.length > 0) {
          const wt = todays[0];
          this.currentWorkingTimeId = wt.id || wt.working_time_id || null;
          const startIso = wt.start_time || wt.startTime || wt.start;
          const endIso = wt.end_time || wt.endTime || wt.end;
          if (startIso) this.scheduleStart = new Date(startIso).toISOString().slice(11, 16);
          if (endIso) this.scheduleEnd = new Date(endIso).toISOString().slice(11, 16);
          if (startIso && endIso) {
            const dur = Math.max(0, Date.parse(endIso) - Date.parse(startIso));
            this.remainingSeconds = Math.floor(dur / 1000);
          }
        }

        const sessions = todays.map((w) => {
          const startIso = w.start_time || w.startTime || w.start;
          const endIso = w.end_time || w.endTime || w.end;
          const startTs = startIso ? Date.parse(startIso) : null;
          const endTs = endIso ? Date.parse(endIso) : null;
          const durMs = startTs && endTs ? Math.max(0, endTs - startTs) : 0;
          const minutes = Math.floor(durMs / 60000);
          const seconds = Math.floor((durMs % 60000) / 1000);
          return {
            checkInTime: startTs ? new Date(startTs).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '--:--',
            checkOutTime: endTs ? new Date(endTs).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '--:--',
            duration: `${minutes}m ${seconds}s`,
            startTs: startTs || undefined,
            endTs: endTs || undefined,
          };
        });
        // Replace local list with server-derived sessions
        this.workSessions = sessions;
      } catch (e) {
        this.sessionsError = 'Failed to load today\'s sessions';
        console.error(e);
      } finally {
        this.sessionsLoading = false;
      }
    },
    async loadUsers() {
      try {
        this.usersLoading = true;
        this.usersError = '';
        const res = await usersApi.list();
        const raw = Array.isArray(res)
          ? res
          : (Array.isArray(res?.data) ? res.data : []);
        // Normalize to the internal UI shape used across components
        this.users = raw.map((u) => ({
          id: u.id ?? u.user_id ?? null,
          first_name: u.first_name ?? u.firstname ?? u.name?.first ?? '',
          last_name: u.last_name ?? u.lastname ?? u.name?.last ?? '',
          profile_name: u.profile_name ?? u.username ?? '',
          email: u.email ?? '',
          // Some backends will not return password; leave undefined for client-only check fallback
          password: u.password
        }));
      } catch (e) {
        this.usersError = 'Failed to load users';
        // keep users as empty
      } finally {
        this.usersLoading = false;
      }
    },
    async handleSignup(newUser) {
      // newUser likely has { first_name, last_name, profile_name, email, password }
      try {
        this.isLoading = true;
        const payload = {
          firstname: newUser.first_name || '',
          lastname: newUser.last_name || '',
          username: newUser.profile_name || newUser.username || '',
          email: newUser.email || '',
          password: newUser.password || ''
        };
        const created = await usersApi.create(payload);
        // Also create today's working_time schedule using start_work_time/end_work_time
        try {
          const startHHMM = newUser.start_work_time || '09:00';
          const endHHMM = newUser.end_work_time || '17:00';
          const today = new Date();
          const datePart = today.toISOString().slice(0,10);
          const startIso = new Date(`${datePart}T${startHHMM}:00`).toISOString();
          const endIso = new Date(`${datePart}T${endHHMM}:00`).toISOString();
          const newUserId = created?.id || created?.data?.id;
          if (newUserId) {
            await workingTimesApi.create({ user_id: newUserId, start_time: startIso, end_time: endIso });
          }
        } catch (e) {
          console.warn('Schedule create failed (signup):', e);
        }
        // After creating, reload list to reflect backend state
        await this.loadUsers();
        this.currentPage = 'signin';
      } catch (e) {
        this.loginError = 'Failed to sign up. Please try again.';
      } finally {
        this.isLoading = false;
      }
    },
    async handleSignin(signinForm) {
      const user = this.users.find(u => u.email === signinForm.email && u.password === signinForm.password);
      if (user) {
        this.isLoading = true;
        this.loginError = '';
        setTimeout(async () => {
          try {
            this.loggedInUser = user;
            this.currentPage = 'homepage';
            this.resetDailyTimer();
            await this.loadTodaySessions();
          } catch (e) {
            console.error(e);
          } finally {
            this.isLoading = false;
          }
        }, 800);
      } else {
        this.loginError = 'Invalid email or password.';
      }
    },
    handleLogout() {
      this.loggedInUser = null;
      this.currentPage = 'signin';
      this.isCheckedIn = false;
      this.checkInTime = null;
      this.checkOutTime = null;
      this.elapsedTime = 0;
      clearInterval(this.intervalId);
    },
    async toggleCheckIn() {
      if (!this.isCheckedIn) {
        // Check for new day and reset if needed
        const today = new Date().toLocaleDateString();
        if (this.lastDate !== today) {
            this.resetDailyTimer();
        }
        this.lastDate = today;

        // Checking in
        this.checkInTime = Date.now();
        this.isCheckedIn = true;
        this.intervalId = setInterval(() => {
          this.elapsedTime++;
        }, 1000);
        // Only create a clockin; require schedule's working_time_id
        try {
          const userId = this.loggedInUser?.id;
          const startIso = new Date(this.checkInTime).toISOString();
          // If no schedule exists yet for today, auto-create from the current scheduleStart/End
          if (!this.currentWorkingTimeId) {
            await this.saveScheduleForToday();
          }
          if (userId && this.currentWorkingTimeId) {
            const ci = await clockinsApi.create({ user_id: userId, working_time_id: this.currentWorkingTimeId, start_time: startIso, in_progress: true });
            const ciId = this.getEntityId(ci);
            if (ciId) this.currentClockinId = ciId;
            else this.clockError = 'Clock-in created but no ID returned';
          } else if (!userId) {
            this.clockError = 'No user logged in';
          } else if (!this.currentWorkingTimeId) {
            this.clockError = 'No working time schedule for today';
          }
        } catch (e) {
          // Non-fatal: keep UI running even if backend fails
          console.error('Check-in API failed', e);
          this.clockError = 'Failed to create clock-in';
        }
      } else {
        // Initiate checkout reason flow
        this.showCheckoutReason = true;
      }
    },
    async confirmCheckout() {
      // Checking out with reason
      this.checkOutTime = Date.now();
      const durationMs = this.checkOutTime - this.checkInTime;
      const minutes = Math.floor(durationMs / 60000);
      const seconds = Math.floor((durationMs % 60000) / 1000);

      this.workSessions.push({
        checkInTime: new Date(this.checkInTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        checkOutTime: new Date(this.checkOutTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        duration: `${minutes}m ${seconds}s`,
        startTs: this.checkInTime,
        endTs: this.checkOutTime,
        reason: this.checkoutReason.trim()
      });
      this.isCheckedIn = false;
      this.showCheckoutReason = false;
      this.checkoutReason = '';
      clearInterval(this.intervalId);

      // Update backend clockin only (working_time is schedule, not auto-updated here)
      try {
        const endIso = new Date(this.checkOutTime).toISOString();
        if (this.currentClockinId) {
          await clockinsApi.update(this.currentClockinId, { in_progress: false, end_time: endIso });
        }
        // Refresh from server so UI reflects persisted data
        await this.loadTodaySessions();
      } catch (e) {
        console.error('Checkout API failed', e);
        this.clockError = 'Failed to close clock-in';
      } finally {
        // Keep currentWorkingTimeId (schedule for today); only clear the open clockin id
        this.currentClockinId = null;
      }
    },
    cancelCheckout() {
      this.showCheckoutReason = false;
      this.checkoutReason = '';
    },
    resetDailyTimer() {
        this.elapsedTime = 0;
        this.workSessions = [];
        this.lastDate = new Date().toLocaleDateString();
    },
    handleEditProfile() {
        if (this.loggedInUser) {
            this.currentPage = 'editProfile';
        }
    },
    handleUpdateProfile(updatedUser) {
        const userIndex = this.users.findIndex(u => u.email === this.loggedInUser.email);
        if (userIndex !== -1) {
            this.users[userIndex] = { ...this.users[userIndex], ...updatedUser };
            this.loggedInUser = { ...this.loggedInUser, ...updatedUser };
            this.currentPage = 'homepage';
        }
    },
    handleDeleteAccount() {
        const userIndex = this.users.findIndex(u => u.email === this.loggedInUser.email);
        if (userIndex !== -1) {
            this.users.splice(userIndex, 1);
            this.handleLogout(); // Log out and reset state
        }
    }
  },
  mounted() {
      // Check if the date has changed since the last visit
      const today = new Date().toLocaleDateString();
      if (this.lastDate && this.lastDate !== today) {
          this.resetDailyTimer();
      }
      // Load users for sign in page
      this.loadUsers();
  }
};
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap');

.app-container {
  background-color: #111827;
  color: #ffffff;
  min-height: 100vh;
  display: flex;
  justify-content: center;
  padding: 1rem;
  font-family: 'Inter', sans-serif;
}

.main-card {
  background-color: rgba(31, 41, 55, 0.7);
  border-radius: 1rem;
  padding: 2rem;
  width: 100%;
  backdrop-filter: blur(8px);
  border: 1px solid #374151;
  position: relative;
  max-width: 1200px;
}

.page-transition {
  transition: opacity 0.5s ease-in-out;
}

.homepage-layout {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.homepage-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  margin-bottom: 2rem;
}

.profile-name-container {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.user-name {
  font-size: 1.5rem;
  font-weight: 800;
  color: #2dd4bf;
  margin: 0;
}

.profile-name {
  font-size: 1rem;
  font-weight: 600;
  color: #d1d5db;
}

.button-group {
    display: flex;
    gap: 0.5rem;
}

.edit-button,
.logout-button {
  background-color: #ef4444;
  color: #ffffff;
  font-weight: bold;
  padding: 0.5rem 1rem;
  border-radius: 0.75rem;
  transition: background-color 0.3s ease;
}

.edit-button {
  background-color: #3b82f6;
}
.edit-button:hover {
  background-color: #2563eb;
}

.logout-button:hover {
  background-color: #dc2626;
}

.main-content-area {
  display: flex;
  justify-content: space-between;
  gap: 2rem;
  flex-wrap: wrap;
}

.left-column,
.right-column {
  flex: 1;
  min-width: 250px;
}

.left-column {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.profile-image-container {
  position: relative;
  width: 6rem;
  height: 6rem;
  margin-bottom: 1rem;
}

.profile-image {
  border-radius: 9999px;
  width: 100%;
  height: 100%;
  object-fit: cover;
  border: 4px solid #2dd4bf;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.date-display {
    font-size: 1.125rem;
    color: #9ca3af;
    margin-bottom: 1rem;
    font-weight: 600;
}

.timer-section {
  width: 100%;
  text-align: left;
}

.timer-label {
  color: #9ca3af;
  font-size: 0.875rem;
}

.timer-display {
  font-size: 3rem;
  font-weight: 800;
  color: #ffffff;
  margin-top: 0.5rem;
  margin-bottom: 1.5rem;
}

.sessions-list-container {
  width: 100%;
}

.sessions-title {
    font-size: 1rem;
    font-weight: 600;
    color: #d1d5db;
    margin-bottom: 0.5rem;
    text-align: left;
}

.sessions-table {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  width: 100%;
}

.table-header {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  font-size: 0.875rem;
  color: #9ca3af;
  font-weight: 600;
  padding: 0 1rem;
}

.session-entry {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  width: 100%;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  background-color: #374151;
  border: 1px solid #4b5563;
  font-size: 0.875rem;
}

.no-sessions {
    color: #9ca3af;
    font-size: 0.875rem;
    text-align: left;
}

.checkin-button {
  width: 100%;
  background-color: #10b981;
  color: #ffffff;
  font-weight: bold;
  padding: 1rem;
  border-radius: 0.75rem;
  transition: background-color 0.3s ease;
}

.checkin-button:hover {
  background-color: #059669;
}

.checkout-button {
  width: 100%;
  background-color: #ef4444;
  color: #ffffff;
  font-weight: bold;
  padding: 1rem;
  border-radius: 0.75rem;
  transition: background-color 0.3s ease;
}

.checkout-button:hover {
  background-color: #dc2626;
}

.checkout-reason-card {
  width: 100%;
  background-color: #1f2937;
  border: 1px solid #374151;
  border-radius: 0.75rem;
  padding: 0.75rem;
  margin-top: 0.75rem;
}

.reason-label {
  display: block;
  color: #d1d5db;
  font-size: 0.875rem;
  margin-bottom: 0.25rem;
}

.reason-input {
  width: 100%;
  background: #111827;
  color: #e5e7eb;
  border: 1px solid #374151;
  border-radius: 0.5rem;
  padding: 0.5rem 0.75rem;
  outline: none;
}

.reason-input:focus {
  border-color: #3b82f6;
}

.reason-actions {
  display: flex;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.confirm-reason {
  background-color: #10b981;
  color: #ffffff;
  font-weight: 600;
  padding: 0.4rem 0.8rem;
  border-radius: 0.5rem;
}

.confirm-reason:hover { background-color: #059669; }

.cancel-reason {
  background-color: #374151;
  color: #e5e7eb;
  font-weight: 600;
  padding: 0.4rem 0.8rem;
  border-radius: 0.5rem;
}

.cancel-reason:hover { background-color: #4b5563; }

.loader-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(17, 24, 39, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

.loader-spinner {
  width: 48px;
  height: 48px;
  border: 5px solid #fff;
  border-bottom-color: #2dd4bf;
  border-radius: 50%;
  display: inline-block;
  box-sizing: border-box;
  animation: rotation 1s linear infinite;
}

@keyframes rotation {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}
</style>
