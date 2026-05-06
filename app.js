const SUPABASE_URL   = 'https://pqcwgbtssyabzalfafcz.supabase.co';
const SUPABASE_ANON  = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxY3dnYnRzc3lhYnphbGZhZmN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwOTAxMjEsImV4cCI6MjA5MzY2NjEyMX0.mGLJWkcKFOx7Axa7kvNDXxwTdBAkkOFnkkSxzrVDv3o';
const HEADERS = {
  'Content-Type': 'application/json',
  'apikey': SUPABASE_ANON,
  'Authorization': `Bearer ${SUPABASE_ANON}`,
  'Prefer': 'return=representation',
};

const taskInput  = document.getElementById('taskInput');
const addBtn     = document.getElementById('addBtn');
const taskList   = document.getElementById('taskList');
const remaining  = document.getElementById('remaining');
const clearDone  = document.getElementById('clearDone');
const filterBtns = document.querySelectorAll('.filter-btn');

let tasks  = [];
let filter = 'all';

async function api(path, options = {}) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1${path}`, {
    ...options,
    headers: { ...HEADERS, ...options.headers },
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.message || res.statusText);
  }
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}

async function loadTasks() {
  setLoading(true);
  try {
    tasks = await api('/tasks?order=created_at.desc');
  } catch (e) {
    showError('Görevler yüklenemedi: ' + e.message);
  } finally {
    setLoading(false);
  }
  render();
}

async function addTask() {
  const text = taskInput.value.trim();
  if (!text) return;
  taskInput.disabled = true;
  addBtn.disabled    = true;
  try {
    const [created] = await api('/tasks', {
      method: 'POST',
      body: JSON.stringify({ text, done: false }),
    });
    tasks.unshift(created);
    taskInput.value = '';
    render();
  } catch (e) {
    showError('Eklenemedi: ' + e.message);
  } finally {
    taskInput.disabled = false;
    addBtn.disabled    = false;
    taskInput.focus();
  }
}

async function toggle(id) {
  const t = tasks.find(t => t.id === id);
  if (!t) return;
  const newDone = !t.done;
  t.done = newDone;
  render();
  try {
    await api(`/tasks?id=eq.${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ done: newDone }),
    });
  } catch (e) {
    t.done = !newDone;
    render();
    showError('Güncellenemedi: ' + e.message);
  }
}

async function remove(id) {
  tasks = tasks.filter(t => t.id !== id);
  render();
  try {
    await api(`/tasks?id=eq.${id}`, { method: 'DELETE' });
  } catch (e) {
    showError('Silinemedi: ' + e.message);
    loadTasks();
  }
}

async function clearCompleted() {
  const doneTasks = tasks.filter(t => t.done);
  if (!doneTasks.length) return;
  tasks = tasks.filter(t => !t.done);
  render();
  try {
    await api('/tasks?done=eq.true', { method: 'DELETE' });
  } catch (e) {
    showError('Temizlenemedi: ' + e.message);
    loadTasks();
  }
}

function render() {
  taskList.innerHTML = '';

  const visible = tasks.filter(t =>
    filter === 'all'    ? true :
    filter === 'active' ? !t.done :
                           t.done
  );

  if (visible.length === 0) {
    taskList.innerHTML = '<p class="empty-msg">Görev yok.</p>';
  } else {
    visible.forEach(t => {
      const li = document.createElement('li');
      li.className = 'task-item' + (t.done ? ' done' : '');

      const cb = document.createElement('input');
      cb.type    = 'checkbox';
      cb.checked = t.done;
      cb.addEventListener('change', () => toggle(t.id));

      const span = document.createElement('span');
      span.className   = 'task-text';
      span.textContent = t.text;

      const del = document.createElement('button');
      del.className   = 'delete-btn';
      del.textContent = '✕';
      del.title       = 'Sil';
      del.addEventListener('click', () => remove(t.id));

      li.append(cb, span, del);
      taskList.appendChild(li);
    });
  }

  const activeCount = tasks.filter(t => !t.done).length;
  remaining.textContent = `${activeCount} görev kaldı`;
}

function setLoading(on) {
  taskList.innerHTML = on ? '<p class="empty-msg">Yükleniyor...</p>' : '';
}

function showError(msg) {
  const el = document.getElementById('error-msg');
  el.textContent = msg;
  el.style.display = 'block';
  setTimeout(() => { el.style.display = 'none'; }, 3500);
}

addBtn.addEventListener('click', addTask);
taskInput.addEventListener('keydown', e => { if (e.key === 'Enter') addTask(); });
clearDone.addEventListener('click', clearCompleted);

filterBtns.forEach(btn => {
  btn.addEventListener('click', () => {
    filterBtns.forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    filter = btn.dataset.filter;
    render();
  });
});

loadTasks();
