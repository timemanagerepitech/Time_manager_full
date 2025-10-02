<template>
  <div class="chatbot-container">
    <div class="chatbot-header" @click="toggleChat">
      <span>bot</span>
      <span class="toggle-icon">{{ isOpen ? '−' : '+' }}</span>
    </div>
    
    <div v-if="isOpen" class="chat-window">
      <div class="messages" ref="messagesContainer">
        <div v-for="(message, index) in messages" :key="index" :class="['message', message.role]">
          <div class="message-content">
            <strong v-if="message.role === 'assistant'">Assistant:</strong>
            <strong v-else>You:</strong>
            {{ message.content }}
          </div>
        </div>
        <div v-if="isLoading" class="typing-indicator">
          <span></span>
          <span></span>
          <span></span>
        </div>
      </div>
      
      <div class="input-area">
        <input
          v-model="userInput"
          @keyup.enter="sendMessage"
          placeholder="Type your message..."
          class="message-input"
          :disabled="isLoading"
        />
        <button @click="sendMessage" class="send-button" :disabled="isLoading">
          {{ isLoading ? 'Sending...' : 'Send' }}
        </button>
      </div>
    </div>
    <div v-else class="chat-closed">
      <div class="chat-icon" @click="toggleChat">💬</div>
    </div>
  </div>
</template>

<script>
import { chatService } from '@/services/chatService';

export default {
  name: 'ChatBot',
  data() {
    return {
      isOpen: false,
      isLoading: false,
      userInput: '',
      messages: [
        {
          role: 'assistant',
          content: 'Hello! I\'m your Time Manager Assistant. How can I help you today?'
        }
      ]
    };
  },
  mounted() {
    console.log('ChatBot component mounted');
    this.scrollToBottom();
  },
  methods: {
    toggleChat() {
      this.isOpen = !this.isOpen;
      console.log('Chat toggled. isOpen:', this.isOpen);
      if (this.isOpen) {
        this.$nextTick(() => {
          this.scrollToBottom();
        });
      }
    },
    async sendMessage() {
      if (!this.userInput.trim() || this.isLoading) return;

      // Add user message
      const userMessage = { role: 'user', content: this.userInput };
      this.messages.push(userMessage);
      this.userInput = '';
      this.isLoading = true;

      try {
        const response = await chatService.sendMessage([
          {
            role: 'system',
            content: `You are an instructional chatbot. Your job is to guide users on how to use the Time Manager website. 
            The website is a time scheduler for employees. Gotham has been overrun by villains and the time management for 
            the employees is in shambles. This website allows users to login, signup, set their own time schedule, 
            clock in/out, and view their work time history and statistics.`
          },
          ...this.messages
        ]);
        
        const assistantMessage = response.choices[0].message;
        this.messages.push(assistantMessage);
      } catch (error) {
        console.error('Error:', error);
        this.messages.push({
          role: 'assistant',
          content: 'Sorry, I encountered an error. Please try again later.'
        });
      } finally {
        this.isLoading = false;
        this.scrollToBottom();
      }
    },
    scrollToBottom() {
      this.$nextTick(() => {
        const container = this.$refs.messagesContainer;
        if (container) {
          container.scrollTop = container.scrollHeight;
        }
      });
    }
  }
};
</script>

<style scoped>
/* Debug styles - can be removed later */
.debug-border {
  border: 2px solid red !important;
}

.chatbot-container {
  position: fixed;
  top: 50px;
  right: 20px;
  width: 350px;
  z-index: 9999;
  font-family: 'Inter', sans-serif;
  box-shadow: 0 5px 25px rgba(0, 0, 0, 0.2);
  border-radius: 12px;
  overflow: hidden;
  transition: all 0.3s ease;
}

.chatbot-header {
  background-color: #4e46e511;
  color: white;
  padding: 15px 20px;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
  font-size: 1.1em;
  transition: background-color 0.2s;
}

.chatbot-header:hover {
  background-color: #4338ca;
}

.toggle-icon {
  font-size: 1.2em;
  font-weight: bold;
}

.chat-window {
  background-color: #f9fafb;
  border: 1px solid #e5e7eb;
  border-top: none;
  display: flex;
  flex-direction: column;
  height: 500px;
  background-color: #ffffff;
  border-radius: 0 0 12px 12px;
}

.messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background-color: #f9fafb;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.message {
  max-width: 80%;
  margin-bottom: 8px;
  line-height: 1.5;
}

.message.user {
  align-self: flex-end;
  text-align: right;
}

.message.assistant {
  align-self: flex-start;
  text-align: left;
}

.message-content {
  display: inline-block;
  padding: 10px 16px;
  border-radius: 18px;
  word-wrap: break-word;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
}

.user .message-content {
  background-color: #4f46e5;
  color: white;
  border-bottom-right-radius: 4px;
}

.assistant .message-content {
  background-color: #ffffff;
  color: #1f2937;
  border: 1px solid #e5e7eb;
  border-bottom-left-radius: 4px;
}

.input-area {
  display: flex;
  padding: 15px;
  border-top: 1px solid #e5e7eb;
  background-color: #ffffff;
  border-radius: 0 0 12px 12px;
}

.message-input {
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  margin-right: 10px;
  outline: none;
  font-size: 14px;
  transition: border-color 0.2s;
}

.message-input:focus {
  border-color: #4f46e5;
}

.send-button {
  padding: 0 20px;
  background-color: #4f46e5;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
  white-space: nowrap;
}

.send-button:disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
  opacity: 0.8;
}

.send-button:not(:disabled):hover {
  background-color: #4338ca;
  transform: translateY(-1px);
}

/* Chat icon when closed */
.chat-closed {
  position: fixed;
  bottom: 20px;
  right: 20px;
  z-index: 9999;
}

.chat-icon {
  width: 60px;
  height: 60px;
  background-color: #4f46e5;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: white;
  cursor: pointer;
  box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
  transition: all 0.3s ease;
}

.chat-icon:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 16px rgba(79, 70, 229, 0.4);
}

/* Typing indicator */
.typing-indicator {
  display: flex;
  padding: 10px 16px;
  background: #ffffff;
  border-radius: 18px;
  align-self: flex-start;
  margin-top: 8px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
}

.typing-indicator span {
  height: 8px;
  width: 8px;
  background-color: #9ca3af;
  border-radius: 50%;
  display: inline-block;
  margin: 0 2px;
  animation: bounce 1.4s infinite ease-in-out both;
}

.typing-indicator span:nth-child(1) {
  animation-delay: -0.32s;
}

.typing-indicator span:nth-child(2) {
  animation-delay: -0.16s;
}

@keyframes bounce {
  0%, 80%, 100% { 
    transform: scale(0);
  } 40% { 
    transform: scale(1.0);
  }
}

/* Scrollbar styling */
.messages::-webkit-scrollbar {
  width: 6px;
}

.messages::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

.messages::-webkit-scrollbar-thumb {
  background: #c7d2fe;
  border-radius: 10px;
}

.messages::-webkit-scrollbar-thumb:hover {
  background: #a5b4fc;
}
</style>
