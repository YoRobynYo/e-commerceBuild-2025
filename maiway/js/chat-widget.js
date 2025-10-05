console.log("LangChain chat-widget loaded (debug)");


// Self-invoking wrapper for safety
(() => {
  // --- Element Selection ---
  const chatWindow = document.getElementById('chatWindow');
  const chatButton = document.getElementById('chatButton');
  const closeChatButton = document.getElementById('closeChat');
  const chatMessages = document.getElementById('chatMessages');
  const messageInput = document.getElementById('messageInput');
  const sendButton = document.getElementById('sendButton');
  const typingIndicator = document.getElementById('typingIndicator');
  const chatNotification = document.getElementById('chatNotification');

  // --- State Management ---
  let isChatOpen = false;
  let unreadCount = 0;
  const API_BASE = "http://localhost:8000"; // Or your production URL

  // --- Core Functions: Open/Close Chat ---
  function openChat() {
    if (isChatOpen) return; // Do nothing if already open
    isChatOpen = true;
    chatWindow.style.display = 'flex';
    document.body.classList.add('chat-open'); // Add class to body
    clearNotifications();
    setTimeout(() => messageInput.focus(), 100); // Small delay to ensure focus works
  }

  function closeChat() {
    if (!isChatOpen) return; // Do nothing if already closed
    isChatOpen = false;
    chatWindow.style.display = 'none';
    document.body.classList.remove('chat-open'); // Remove class from body
  }

  function toggleChat() {
    isChatOpen ? closeChat() : openChat();
  }

  // --- Notification Badge Functions ---
  function updateNotificationBadge(count) {
    unreadCount = count;
    if (chatNotification) {
      if (unreadCount > 0) {
        chatNotification.textContent = unreadCount;
        chatNotification.style.display = 'flex';
      } else {
        chatNotification.style.display = 'none';
      }
    }
  }

  function clearNotifications() {
    updateNotificationBadge(0);
  }

  // --- Message Handling Functions ---
  function escapeHtml(text) {
    const div = document.createElement('div');
    div.appendChild(document.createTextNode(text || ''));
    return div.innerHTML;
  }

  function appendBubble(sender, text) {
    if (!text || !chatMessages) return;
    const messageHtml = `
      <div class="message ${sender}">
        <div class="bubble">
          ${escapeHtml(text)}
        </div>
      </div>
    `;
    chatMessages.insertAdjacentHTML('beforeend', messageHtml);
    chatMessages.scrollTop = chatMessages.scrollHeight;

    // If a bot message arrives and chat is closed, show a notification
    if (sender === 'bot' && !isChatOpen) {
      updateNotificationBadge(unreadCount + 1);
    }
  }

  async function handleSend() {
    const userInputText = (messageInput.value || '').trim();
    if (!userInputText) return;

    appendBubble('user', userInputText);
    messageInput.value = '';
    if (typingIndicator) typingIndicator.style.display = 'flex'; // Use flex for consistency

    try {
      const res = await fetch(`${API_BASE}/api/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user_input: userInputText })
      });

      if (!res.ok) {
        throw new Error(`API error: ${res.statusText}`);
      }

      const data = await res.json();
      const reply = data.reply ?? data.response ?? data.message ?? 'No reply found.';
      appendBubble('bot', reply);
    } catch (err) {
      appendBubble('bot', 'Sorry, there was a problem contacting the AI service.');
      console.error('Chat API error:', err);
    } finally {
      if (typingIndicator) typingIndicator.style.display = 'none';
    }
  }

  // --- Event Listeners ---
  if (chatButton) chatButton.addEventListener('click', toggleChat);
  if (closeChatButton) closeChatButton.addEventListener('click', closeChat);
  if (sendButton) sendButton.addEventListener('click', handleSend);
  if (messageInput) {
    messageInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        handleSend();
      }
    });
  }
  
  // Wire up Quick Replies (if any exist)
  document.body.addEventListener('click', function(event) {
    if (event.target.classList.contains('quick-reply')) {
      const replyText = event.target.getAttribute('data-reply');
      messageInput.value = replyText;
      handleSend();
    }
  });

  // --- Initialization ---
  // Show an initial notification after 2 seconds to encourage interaction
  setTimeout(() => {
    if (!isChatOpen && unreadCount === 0) {
      updateNotificationBadge(1);
    }
  }, 2000);

})();







// code updated above 



// // Notification counter
// let unreadCount = 0;

// document.addEventListener('DOMContentLoaded', function() {
//   const chatWindow = document.getElementById('chatWindow');
//   // if (chatWindow) chatWindow.style.display = 'block'; // Removed to allow CSS to control initial display
// });

// // Self-invoking wrapper for safety
// (() => {
//   // Elements
//   const chatWindow = document.getElementById('chatWindow');
//   const chatButton = document.getElementById('chatButton');
//   const closeChat = document.getElementById('closeChat');
//   const chatMessages = document.getElementById('chatMessages');
//   const messageInput = document.getElementById('messageInput');
//   const sendButton = document.getElementById('sendButton');
//   const typingIndicator = document.getElementById('typingIndicator');
//   const chatNotification = document.getElementById('chatNotification');

//   let isChatOpen = false;

//   // Show initial notification after 2 seconds (optional welcome message)
//   setTimeout(() => {
//     if (!isChatOpen) {
//       updateNotificationBadge(1);
//     }
//   }, 2000);

//   // Toggle chat window
//   if (chatButton) {
//     chatButton.addEventListener('click', () => {
//       isChatOpen = !isChatOpen;
//       chatWindow.style.display = isChatOpen ? 'flex' : 'none';
//       if (isChatOpen) {
//         clearNotifications();
//         messageInput.focus();
//       }
//     });
//   }

//   // Close chat
//   if (closeChat) {
//     closeChat.addEventListener('click', () => {
//       isChatOpen = false;
//       chatWindow.style.display = 'none';
//     });
//   }

//   // Update notification badge
//   function updateNotificationBadge(count) {
//     unreadCount = count;
//     if (chatNotification) {
//       if (unreadCount > 0) {
//         chatNotification.textContent = unreadCount;
//         chatNotification.style.display = 'flex';
//       } else {
//         chatNotification.style.display = 'none';
//       }
//     }
//   }

//   // Clear notifications when chat opens
//   function clearNotifications() {
//     updateNotificationBadge(0);
//   }

//   // Absolute API base
//   const API_BASE = "http://localhost:8000";

//   function escapeHtml(text) {
//     const div = document.createElement('div');
//     div.appendChild(document.createTextNode(text || ''));
//     return div.innerHTML;
//   }

//   function appendBubble(sender, text) {
//     if (!text) return;
//     const wrap = document.createElement('div');
//     wrap.className = 'message ' + (sender === 'user' ? 'user' : 'bot');
//     const bubble = document.createElement('div');
//     bubble.className = 'bubble';
//     bubble.innerHTML = escapeHtml(text);
//     wrap.appendChild(bubble);
//     chatMessages.appendChild(wrap);
//     chatMessages.scrollTop = chatMessages.scrollHeight;

//     // If it's a bot message and chat is closed, increment notification
//     if (sender === 'bot' && !isChatOpen) {
//       updateNotificationBadge(unreadCount + 1);
//     }
//   }

//   async function handleSend() {
//     const userInputText = (messageInput.value || '').trim();
//     if (!userInputText) return;

//     // show user message
//     appendBubble('user', userInputText);
//     messageInput.value = '';

//     // show typing indicator
//     if (typingIndicator) typingIndicator.style.display = 'block';

//     try {
//       const res = await fetch(`${API_BASE}/api/chat`, {
//         method: 'POST',
//         headers: { 'Content-Type': 'application/json' },
//         body: JSON.stringify({ user_input: userInputText })
//       });
//       const data = await res.json();
//       const reply = data.reply ?? data.response ?? data.message ?? '';

//       // hide typing indicator and show bot reply
//       if (typingIndicator) typingIndicator.style.display = 'none';
//       appendBubble('bot', reply);
//     } catch (err) {
//       if (typingIndicator) typingIndicator.style.display = 'none';
//       appendBubble('bot', 'Sorry, there was a problem contacting the AI service.');
//       console.error('Chat API error:', err);
//     }
//   }

//   // Wire up events
//   if (sendButton) sendButton.addEventListener('click', handleSend);
//   if (messageInput) {
//     messageInput.addEventListener('keydown', (e) => {
//       if (e.key === 'Enter' && !e.shiftKey) {
//         e.preventDefault();
//         handleSend();
//       }
//     });
//   }

//   // Quick reply buttons
//   const quickReplyButtons = document.querySelectorAll('.quick-reply');
//   quickReplyButtons.forEach(button => {
//     button.addEventListener('click', () => {
//       const replyText = button.getAttribute('data-reply');
//       messageInput.value = replyText;
//       handleSend();
//     });
//   });

// })();