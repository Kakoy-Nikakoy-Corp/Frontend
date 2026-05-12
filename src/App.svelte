<script>
  import { fade, fly } from 'svelte/transition';
  
  // ─── Состояние приложения ───
  let step = $state('upload'); // upload | preview | processing | success | error
  let videoFile = $state(null);
  let videoUrl = $state(null);
  let isDragging = $state(false);
  
  // Переменные для анимации лупы
  let lensX = $state(10);
  let lensY = $state(10);
  
  let timecodes = $state([]);
  let processingTimer = null;
  let moveTimer = null;
  
  // ─── Логика логотипа ───
  let logoFailed = $state(false);
  
  // ─── Обработчики загрузки файла ───
  let fileInput;
  
  function handleFile(file) {
    if (!file) return;
    
    if (!file.type.startsWith('video/')) {
      alert('Пожалуйста, загрузите видеофайл (MP4, WebM, AVI и т.д.)');
      return;
    }
    
    const maxSize = 500 * 1024 * 1024; // 500 MB
    if (file.size > maxSize) {
      alert('Файл слишком большой. Максимальный размер 500MB');
      return;
    }
    
    videoFile = file;
    videoUrl = URL.createObjectURL(file);
    step = 'preview';
  }
  
  function triggerFileInput() {
    if (fileInput) {
      fileInput.click();
    }
  }
  
  function onDrop(e) {
    e.preventDefault();
    isDragging = false;
    const file = e.dataTransfer.files[0];
    handleFile(file);
  }
  
  function onDragOver(e) {
    e.preventDefault();
    isDragging = true;
  }
  
  function onDragLeave() {
    isDragging = false;
  }
  
  // ─── Отправка на анализ ───
  async function handleSubmit() {
    if (!videoFile) return;
    
    step = 'processing';
    
    moveTimer = setInterval(() => {
      lensX = Math.floor(Math.random() * 80) + 10;
      lensY = Math.floor(Math.random() * 70) + 15;
    }, 600);
    
    processingTimer = setTimeout(async () => {
      clearInterval(moveTimer);
      
      // 🔽 ЗАМЕНИТЕ ЭТОТ БЛОК НА РЕАЛЬНЫЙ FETCH К ВАШЕМУ API
      /*
      const formData = new FormData();
      formData.append('video', videoFile);
      
      try {
        const res = await fetch('api/analyze', { method: 'POST', body: formData });
        const data = await res.json();
        if (data.found) { timecodes = data.timecodes; step = 'success'; }
        else { step = 'error'; }
      } catch (err) { step = 'error'; }
      */
      
      // MOCK-ответ для демо
      const mockSuccess = Math.random() > 0.4;
      if (mockSuccess) {
        timecodes = [
          '00:00:00 - 00:00:28', '00:03:01 - 00:04:04', '00:10:20 - 00:15:04',
          '01:00:00 - 01:00:28', '01:03:01 - 01:04:04', '01:10:20 - 01:15:04',
          '02:00:00 - 02:00:28', '02:03:01 - 02:04:04', '02:10:20 - 02:15:04',
          '03:03:01 - 03:04:04', '03:10:20 - 03:15:04'
        ];
        step = 'success';
      } else {
        step = 'error';
      }
      // 🔼 КОНЕЦ MOCK-БЛОКА
      
    }, 3000);
  }
  
  // ─── Скачивание таймкодов ───
  function downloadTimecodes() {
    const content = timecodes.join('\n');
    const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    
    const a = document.createElement('a');
    a.href = url;
    a.download = `leopard_timecodes_${Date.now()}.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    
    URL.revokeObjectURL(url);
  }
  
  // ─── Сброс потока ───
  function resetFlow() {
    if (processingTimer) clearTimeout(processingTimer);
    if (moveTimer) clearInterval(moveTimer);
    if (videoUrl) URL.revokeObjectURL(videoUrl);
    
    videoFile = null;
    videoUrl = null;
    timecodes = [];
    lensX = 10;
    lensY = 10;
    step = 'upload';
  }
  
  // ─── Очистка при уничтожении компонента ───
  $effect(() => {
    return () => {
      if (processingTimer) clearTimeout(processingTimer);
      if (moveTimer) clearInterval(moveTimer);
      if (videoUrl) URL.revokeObjectURL(videoUrl);
    };
  });
</script>

<div class="app">
  <!-- Логотип PNG с фоллбэком на текст -->
  <header class="logo">
    {#if !logoFailed}
      <img
        src="logo.png"
        alt="Сбер"
        class="logo-img"
        onerror={() => logoFailed = true}
      />
    {:else}
      <span class="logo-text">Сбер</span>
    {/if}
  </header>

  <main class="container">
    <!-- 1. Экран загрузки -->
    {#if step === 'upload'}
      <div 
        class="card upload-card"
        class:active={isDragging}
        ondragover={onDragOver}
        ondragleave={onDragLeave}
        ondrop={onDrop}
      >
        <div class="upload-area">
          <input 
            type="file" 
            id="video-input" 
            accept="video/*" 
            hidden
            bind:this={fileInput}
            onchange={(e) => handleFile(e.target.files[0])}
          />
          <span class="upload-text">Перетащите файл видео сюда</span>
          <span class="upload-or">или</span>
          <button class="btn primary" type="button" onclick={triggerFileInput}>Загрузить файл</button>
        </div>
      </div>
      <div class="actions">
        <button class="btn" disabled>Отправить</button>
      </div>
    {/if}

    <!-- 2. Экран превью -->
    {#if step === 'preview'}
      <div class="card preview-card">
        <video src={videoUrl} controls class="video-preview"></video>
      </div>
      <div class="actions">
        <button class="btn primary" onclick={handleSubmit}>Отправить</button>
      </div>
    {/if}

    <!-- 3. Экран обработки (анимация) -->
    {#if step === 'processing'}
      <div class="card processing-card">
        <div class="scene">
          <img src="leopard.png" alt="Ищем снежного барса" class="leopard-img" />
          <div class="magnifier" style="left: {lensX}%; top: {lensY}%;">🔍</div>
        </div>
      </div>
      <div class="actions">
        <button class="btn" disabled>Ищем барса!</button>
      </div>
    {/if}

    <!-- 4. Успех -->
    {#if step === 'success'}
      <div class="card result-card" transition:fly={{ y: 20, duration: 300 }}>
        <h2 class="result-title">Барс найден</h2>
        <ul class="timecodes-list">
          {#each timecodes as tc}
            <li>{tc}</li>
          {/each}
        </ul>
      </div>
      <div class="actions row">
        <button class="btn primary" onclick={downloadTimecodes}>Скачать файл с таймкодами</button>
        <button class="btn" onclick={resetFlow}>Отправить новое видео</button>
      </div>
    {/if}

    <!-- 5. Ошибка -->
    {#if step === 'error'}
      <div class="card result-card error" transition:fly={{ y: 20, duration: 300 }}>
        <p class="error-text">К сожалению на видео не обнаружено барса</p>
      </div>
      <div class="actions">
        <button class="btn" onclick={resetFlow}>Отправить новое видео</button>
      </div>
    {/if}
  </main>
</div>

<style>
  :global(body) {
    margin: 0;
    font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: #F5F7FA;
    color: #1A1A1A;
  }

  .app {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 24px;
  }

  .logo {
    width: 100%;
    max-width: 800px;
    margin-bottom: 24px;
    display: flex;
    justify-content: flex-start;
    align-items: center;
  }

  .logo-img {
    height: 32px;
    width: auto;
    display: block;
  }

  .logo-text {
    font-weight: 700;
    font-size: 22px;
    color: #21A038;
    letter-spacing: -0.5px;
  }

  .container {
    width: 100%;
    max-width: 560px;
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .card {
    background: #fff;
    border: 1px solid #E2E8F0;
    border-radius: 24px;
    padding: 32px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 240px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.04);
  }

  .upload-card {
    border: 2px dashed #CBD5E1;
    transition: border-color 0.2s, background 0.2s;
    cursor: pointer;
  }
  .upload-card.active {
    border-color: #21A038;
    background: #F0FDF4;
  }

  .upload-area { text-align: center; }
  .upload-text { display: block; font-size: 16px; margin-bottom: 8px; color: #475569; }
  .upload-or { display: block; margin: 8px 0 16px; color: #94A3B8; font-size: 14px; }

  .video-preview { width: 100%; border-radius: 16px; background: #000; max-height: 320px; }

  .scene {
    position: relative;
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 200px;
  }
  .leopard-img {
    max-width: 100%;
    max-height: 200px;
    object-fit: contain;
    filter: drop-shadow(0 4px 6px rgba(0,0,0,0.1));
  }
  .magnifier {
    position: absolute;
    font-size: 42px;
    transition: left 0.6s cubic-bezier(0.25, 1, 0.5, 1), top 0.6s cubic-bezier(0.25, 1, 0.5, 1);
    transform: translate(-50%, -50%);
    pointer-events: none;
    z-index: 2;
  }

  .result-title { margin: 0 0 16px; font-size: 18px; font-weight: 600; text-align: center; }
  .timecodes-list {
    list-style: none; padding: 0; margin: 0; width: 100%; max-height: 180px; overflow-y: auto;
    text-align: center; font-family: 'Courier New', monospace; font-size: 14px; color: #334155;
    line-height: 1.8; background: #F8FAFC; padding: 16px; border-radius: 12px;
  }
  .error-text { margin: 0; font-size: 18px; font-weight: 500; text-align: center; color: #475569; }

  .actions { display: flex; justify-content: center; gap: 12px; }
  .actions.row { flex-direction: column; }
  @media (min-width: 640px) { .actions.row { flex-direction: row; } }

  .btn {
    padding: 12px 24px; border-radius: 12px; border: none; background: #E2E8F0; color: #475569;
    font-size: 15px; font-weight: 500; cursor: pointer; transition: all 0.2s; white-space: nowrap;
  }
  .btn:hover:not(.btn:disabled) { background: #CBD5E1; transform: translateY(-1px); }
  .btn.primary { background: #21A038; color: #fff; }
  .btn.primary:hover:not(.btn:disabled) { background: #1E8E32; box-shadow: 0 4px 12px rgba(33, 160, 56, 0.3); }
  .btn:disabled { opacity: 0.5; cursor: not-allowed; }

  .timecodes-list::-webkit-scrollbar { width: 6px; }
  .timecodes-list::-webkit-scrollbar-track { background: #F1F5F9; border-radius: 3px; }
  .timecodes-list::-webkit-scrollbar-thumb { background: #CBD5E1; border-radius: 3px; }
  .timecodes-list::-webkit-scrollbar-thumb:hover { background: #94A3B8; }
</style>