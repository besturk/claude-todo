const SUPABASE_URL  = 'https://pqcwgbtssyabzalfafcz.supabase.co';
const ANON_KEY      = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxY3dnYnRzc3lhYnphbGZhZmN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwOTAxMjEsImV4cCI6MjA5MzY2NjEyMX0.mGLJWkcKFOx7Axa7kvNDXxwTdBAkkOFnkkSxzrVDv3o';

/* ── helpers ── */
function $(id) { return document.getElementById(id); }

function authHeaders(token) {
  return {
    'Content-Type': 'application/json',
    'apikey': ANON_KEY,
    'Authorization': `Bearer ${token || ANON_KEY}`,
  };
}

async function authFetch(path, options = {}, token = null) {
  const res = await fetch(`${SUPABASE_URL}/auth/v1${path}`, {
    ...options,
    headers: { ...authHeaders(token), ...options.headers },
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(body.error_description || body.msg || body.message || 'Hata oluştu');
  return body;
}

async function dbFetch(path, options = {}) {
  const token = session?.access_token;
  const res = await fetch(`${SUPABASE_URL}/rest/v1${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'apikey': ANON_KEY,
      'Authorization': `Bearer ${token}`,
      'Prefer': 'return=representation',
      ...options.headers,
    },
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.message || res.statusText);
  }
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}

/* ── state ── */
let session      = JSON.parse(sessionStorage.getItem('sb_session') || 'null');
let pendingEmail = '';
let tasks        = [];
let filter       = 'all';

/* ── screens ── */
function showScreen(name) {
  $('authWrap').classList.toggle('hidden', name === 'app');
  $('appWrap').classList.toggle('hidden', name !== 'app');

  ['screenLogin','screenRegister','screenOtp'].forEach(id => {
    $(id).classList.add('hidden');
  });
  if (name !== 'app') $(name).classList.remove('hidden');
}

function showError(elId, msg) {
  const el = $(elId);
  el.textContent = msg;
  el.style.display = 'block';
  setTimeout(() => { el.style.display = 'none'; }, 4000);
}

/* ── auth ── */
async function register() {
  const email    = $('registerEmail').value.trim();
  const password = $('registerPassword').value;
  if (!email || !password) return showError('registerError', 'E-posta ve şifre gerekli.');
  if (password.length < 6)  return showError('registerError', 'Şifre en az 6 karakter olmalı.');

  $('registerBtn').disabled = true;
  $('registerBtn').textContent = 'Kaydediliyor...';
  try {
    await authFetch('/signup', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    pendingEmail = email;
    showScreen('screenOtp');
    otpBoxes[0].focus();
  } catch (e) {
    showError('registerError', e.message);
  } finally {
    $('registerBtn').disabled = false;
    $('registerBtn').textContent = 'Kayıt Ol';
  }
}

async function login() {
  const email    = $('loginEmail').value.trim();
  const password = $('loginPassword').value;
  if (!email || !password) return showError('loginError', 'E-posta ve şifre gerekli.');

  $('loginBtn').disabled = true;
  $('loginBtn').textContent = 'Giriş yapılıyor...';
  try {
    const data = await authFetch('/token?grant_type=password', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    setSession(data);
    enterApp();
  } catch (e) {
    showError('loginError', e.message);
  } finally {
    $('loginBtn').disabled = false;
    $('loginBtn').textContent = 'Giriş Yap';
  }
}

async function verifyOtp() {
  const token = otpBoxes.map(b => b.value).join('');
  if (token.length !== 6) return showError('otpError', '6 haneli kodu eksiksiz girin.');

  $('otpBtn').disabled = true;
  $('otpBtn').textContent = 'Doğrulanıyor...';
  try {
    const data = await authFetch('/verify', {
      method: 'POST',
      body: JSON.stringify({ type: 'signup', email: pendingEmail, token }),
    });
    setSession(data);
    enterApp();
  } catch (e) {
    showError('otpError', 'Kod hatalı veya süresi dolmuş.');
    otpBoxes.forEach(b => { b.value = ''; b.classList.remove('filled'); });
    otpBoxes[0].focus();
  } finally {
    $('otpBtn').disabled = false;
    $('otpBtn').textContent = 'Doğrula';
  }
}

async function resendOtp() {
  if (!pendingEmail) return;
  try {
    await authFetch('/resend', {
      method: 'POST',
      body: JSON.stringify({ type: 'signup', email: pendingEmail }),
    });
    showError('otpError', 'Kod tekrar gönderildi.');
    $('otpError').style.background = '#f0fdf4';
    $('otpError').style.color = '#16a34a';
    $('otpError').style.borderColor = '#bbf7d0';
  } catch (e) {
    showError('otpError', e.message);
  }
}

function setSession(data) {
  session = { access_token: data.access_token, user: data.user };
  sessionStorage.setItem('sb_session', JSON.stringify(session));
}

function logout() {
  session = null;
  sessionStorage.removeItem('sb_session');
  tasks = [];
  showScreen('screenLogin');
}

function enterApp() {
  $('userEmail').textContent = session.user.email;
  showScreen('app');
  loadTasks();
}

/* ── OTP input UX ── */
const otpBoxes = Array.from(document.querySelectorAll('.otp-box'));

otpBoxes.forEach((box, i) => {
  box.addEventListener('input', () => {
    const val = box.value.replace(/\D/g, '');
    box.value = val;
    box.classList.toggle('filled', val !== '');
    if (val && i < otpBoxes.length - 1) otpBoxes[i + 1].focus();
    if (otpBoxes.every(b => b.value)) verifyOtp();
  });
  box.addEventListener('keydown', e => {
    if (e.key === 'Backspace' && !box.value && i > 0) {
      otpBoxes[i - 1].value = '';
      otpBoxes[i - 1].classList.remove('filled');
      otpBoxes[i - 1].focus();
    }
  });
  box.addEventListener('paste', e => {
    e.preventDefault();
    const text = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6);
    text.split('').forEach((ch, j) => {
      if (otpBoxes[j]) { otpBoxes[j].value = ch; otpBoxes[j].classList.add('filled'); }
    });
    if (text.length === 6) verifyOtp();
    else if (otpBoxes[text.length]) otpBoxes[text.length].focus();
  });
});

/* ── tasks ── */
async function loadTasks() {
  $('taskList').innerHTML = '<p class="empty-msg">Yükleniyor...</p>';
  try {
    tasks = await dbFetch('/tasks?order=created_at.desc');
    render();
  } catch (e) {
    showError('appError', 'Görevler yüklenemedi: ' + e.message);
    $('taskList').innerHTML = '';
  }
}

async function addTask() {
  const text = $('taskInput').value.trim();
  if (!text) return;
  $('taskInput').disabled = true;
  $('addBtn').disabled    = true;
  try {
    const [created] = await dbFetch('/tasks', {
      method: 'POST',
      body: JSON.stringify({ text, done: false, user_id: session.user.id }),
    });
    tasks.unshift(created);
    $('taskInput').value = '';
    render();
  } catch (e) {
    showError('appError', 'Eklenemedi: ' + e.message);
  } finally {
    $('taskInput').disabled = false;
    $('addBtn').disabled    = false;
    $('taskInput').focus();
  }
}

async function toggle(id) {
  const t = tasks.find(t => t.id === id);
  if (!t) return;
  t.done = !t.done;
  render();
  try {
    await dbFetch(`/tasks?id=eq.${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ done: t.done }),
    });
  } catch (e) {
    t.done = !t.done;
    render();
    showError('appError', 'Güncellenemedi: ' + e.message);
  }
}

async function remove(id) {
  tasks = tasks.filter(t => t.id !== id);
  render();
  try {
    await dbFetch(`/tasks?id=eq.${id}`, { method: 'DELETE' });
  } catch (e) {
    showError('appError', 'Silinemedi: ' + e.message);
    loadTasks();
  }
}

async function clearCompleted() {
  const had = tasks.filter(t => t.done);
  if (!had.length) return;
  tasks = tasks.filter(t => !t.done);
  render();
  try {
    await dbFetch('/tasks?done=eq.true', { method: 'DELETE' });
  } catch (e) {
    showError('appError', 'Temizlenemedi: ' + e.message);
    loadTasks();
  }
}

function render() {
  const list = $('taskList');
  list.innerHTML = '';
  const visible = tasks.filter(t =>
    filter === 'all'    ? true :
    filter === 'active' ? !t.done : t.done
  );
  if (!visible.length) {
    list.innerHTML = '<p class="empty-msg">Görev yok.</p>';
  } else {
    visible.forEach(t => {
      const li   = document.createElement('li');
      li.className = 'task-item' + (t.done ? ' done' : '');

      const cb = document.createElement('input');
      cb.type = 'checkbox'; cb.checked = t.done;
      cb.addEventListener('change', () => toggle(t.id));

      const span = document.createElement('span');
      span.className = 'task-text'; span.textContent = t.text;

      const del = document.createElement('button');
      del.className = 'delete-btn'; del.textContent = '✕'; del.title = 'Sil';
      del.addEventListener('click', () => remove(t.id));

      li.append(cb, span, del);
      list.appendChild(li);
    });
  }
  $('remaining').textContent = `${tasks.filter(t => !t.done).length} görev kaldı`;
}

/* ── event listeners ── */
$('registerBtn').addEventListener('click', register);
$('loginBtn').addEventListener('click', login);
$('otpBtn').addEventListener('click', verifyOtp);
$('resendOtp').addEventListener('click', e => { e.preventDefault(); resendOtp(); });
$('logoutBtn').addEventListener('click', logout);
$('addBtn').addEventListener('click', addTask);
$('taskInput').addEventListener('keydown', e => { if (e.key === 'Enter') addTask(); });
$('clearDone').addEventListener('click', clearCompleted);
$('goRegister').addEventListener('click', e => { e.preventDefault(); showScreen('screenRegister'); });
$('goLogin').addEventListener('click',    e => { e.preventDefault(); showScreen('screenLogin'); });
$('loginPassword').addEventListener('keydown', e => { if (e.key === 'Enter') login(); });
$('registerPassword').addEventListener('keydown', e => { if (e.key === 'Enter') register(); });

document.querySelectorAll('.filter-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    filter = btn.dataset.filter;
    render();
  });
});

/* ── init ── */
if (session?.access_token) {
  enterApp();
} else {
  showScreen('screenLogin');
}
