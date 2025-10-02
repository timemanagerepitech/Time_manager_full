import axios from 'axios';

const API_URL = 'http://localhost:4000/api/chat';

export const chatService = {
  async sendMessage(messages) {
    try {
      const response = await axios.post(API_URL, { messages });
      return response.data;
    } catch (error) {
      console.error('Error sending message to chatbot:', error);
      throw error;
    }
  }
};
