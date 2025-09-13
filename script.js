// Simple interactivity: mobile menu toggle and year injection
(function () {
  const menuBtn = document.querySelector('[data-menu]');
  const links = document.querySelector('[data-links]');
  if (menuBtn && links) {
    menuBtn.addEventListener('click', () => {
      links.classList.toggle('show');
    });
  }
  const yearEl = document.querySelector('[data-year]');
  if (yearEl) yearEl.textContent = new Date().getFullYear();
})();

// EmailJS booking form handling
(function () {
  const form = document.getElementById('booking-form');
  if (!form) return;

  const sendBtn = document.getElementById('send-btn');
  const buttonText = document.getElementById('button-text');
  const buttonSpinner = document.getElementById('button-spinner');
  const formAlert = document.getElementById('form-alert');

  // Show alert message
  function showAlert(message, type = 'error') {
    formAlert.textContent = message;
    formAlert.style.display = 'block';
    formAlert.style.backgroundColor = type === 'error' ? '#ffebee' : '#e8f5e9';
    formAlert.style.color = type === 'error' ? '#b00020' : '#1a7f37';
    formAlert.style.borderLeft = `4px solid ${type === 'error' ? '#b00020' : '#1a7f37'}`;
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
      formAlert.style.display = 'none';
    }, 10000);
  }

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    // Validate form
    if (!form.checkValidity()) {
      form.reportValidity();
      return;
    }

    // Show loading state
    sendBtn.disabled = true;
    buttonText.style.display = 'none';
    buttonSpinner.style.display = 'inline-block';
    formAlert.style.display = 'none';

    try {
      // Prepare form data
      const formData = {
        from_name: form.name.value,
        from_email: form.email.value,
        phone: form.phone.value,
        service: form.service.value,
        dates: form.dates.value,
        message: form.message.value,
        to_email: 'greatkapiris@gmail.com', // Your email
        subject: `New Booking Request: ${form.service.value}`
      };

      // Send email using EmailJS
      const response = await emailjs.send(
        'service_ft84hwu', // Your EmailJS service ID
        'template_oo8e6mo', // Your EmailJS template ID
        formData
      );

      if (response.status === 200) {
        // Show success message
        showAlert('Your booking request has been sent successfully! We\'ll get back to you soon.', 'success');
        form.reset();
      } else {
        throw new Error('Failed to send message');
      }
    } catch (error) {
      console.error('Error sending email:', error);
      showAlert(`Failed to send message. Please try again or contact us directly at greatkapiris@gmail.com. Error: ${error.message}`, 'error');
    } finally {
      // Reset button state
      sendBtn.disabled = false;
      buttonText.style.display = 'inline-block';
      buttonSpinner.style.display = 'none';
    }
  });
})();


