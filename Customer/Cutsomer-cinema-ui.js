 const ROWS = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N'];
  const SEATS_PER_SECTION = 8;
  const VIP_ROWS = ['E','F','G'];
  const STD_PRICE = 12;
  const VIP_PRICE = 22;
  const TOTAL_SEATS = ROWS.length * SEATS_PER_SECTION * 2; // 224
 
  const movies = [
    { name: 'Dune: Part Three',    meta: '2h 48m &nbsp;|&nbsp; PG-13<br>Hall A &nbsp;|&nbsp; 4K Dolby', genre: 'Sci-Fi',   badge: 'badge-purple' },
    { name: 'Echoes of Tomorrow',  meta: '1h 55m &nbsp;|&nbsp; PG<br>Hall B &nbsp;|&nbsp; IMAX',        genre: 'Drama',    badge: 'badge-purple' },
    { name: 'The Last Horizon',    meta: '2h 12m &nbsp;|&nbsp; R<br>Hall C &nbsp;|&nbsp; Standard',     genre: 'Thriller', badge: 'badge-amber'  },
  ];
 
  let seatState = {};
  let selected = new Set();
 
  function isVIP(row) { return VIP_ROWS.includes(row); }
 
  function seatKey(row, section, num) { return `${row}${section}${num}`; }
 
  function initSeats() {
    seatState = {};
    selected.clear();
    ROWS.forEach(r => {
      ['L','R'].forEach(sec => {
        for (let n = 1; n <= SEATS_PER_SECTION; n++) {
          seatState[seatKey(r, sec, n)] = 'available';
        }
      });
    });
  }
 
  function getSeatClass(key) {
    const row = key[0];
    const s = seatState[key];
    if (s === 'taken')    return 'seat taken';
    if (s === 'selected') return isVIP(row) ? 'seat selected' : 'seat selected';
    return isVIP(row) ? 'seat available' : 'seat available';
  }
 
  function buildGrid() {
    const grid = document.getElementById('seat-grid');
    grid.innerHTML = '';
 
    ROWS.forEach(r => {
      const rowEl = document.createElement('div');
      rowEl.className = 'row';
 
      // Row label left
      const lblL = document.createElement('div');
      lblL.className = 'row-lbl';
      lblL.textContent = r;
      rowEl.appendChild(lblL);
 
      // Left section (seats 8→1, so seat 1 is closest to aisle)
      const secL = document.createElement('div');
      secL.className = 'section';
      for (let n = SEATS_PER_SECTION; n >= 1; n--) {
        const key = seatKey(r, 'L', n);
        const seat = document.createElement('div');
        seat.className = getSeatClass(key);
        seat.dataset.key = key;
        seat.title = `${isVIP(r) ? 'VIP ' : ''}Row ${r} · Left ${n}`;
        if (seatState[key] !== 'taken') {
          seat.addEventListener('click', () => toggleSeat(key));
        }
        secL.appendChild(seat);
      }
      rowEl.appendChild(secL);
 
      // Center aisle
      const aisle = document.createElement('div');
      aisle.className = 'center-aisle';
      rowEl.appendChild(aisle);
 
      // Right section (seats 1→8, seat 1 closest to aisle)
      const secR = document.createElement('div');
      secR.className = 'section';
      for (let n = 1; n <= SEATS_PER_SECTION; n++) {
        const key = seatKey(r, 'R', n);
        const seat = document.createElement('div');
        seat.className = getSeatClass(key);
        seat.dataset.key = key;
        seat.title = `${isVIP(r) ? 'VIP ' : ''}Row ${r} · Right ${n}`;
        if (seatState[key] !== 'taken') {
          seat.addEventListener('click', () => toggleSeat(key));
        }
        secR.appendChild(seat);
      }
      rowEl.appendChild(secR);
 
      // Row label right
      const lblR = document.createElement('div');
      lblR.className = 'row-lbl';
      lblR.textContent = r;
      rowEl.appendChild(lblR);
 
      grid.appendChild(rowEl);
    });
  }
 
  function refreshSeat(key) {
    const el = document.querySelector(`[data-key="${key}"]`);
    if (!el) return;
    el.className = getSeatClass(key);
    if (seatState[key] === 'taken') {
      const clone = el.cloneNode(true);
      el.replaceWith(clone);
    }
  }
 
  function toggleSeat(key) {
    if (seatState[key] === 'taken') return;
    if (seatState[key] === 'selected') {
      seatState[key] = 'available';
      selected.delete(key);
    } else {
      if (selected.size >= 10) { showToast('Max 10 seats per booking', false); return; }
      seatState[key] = 'selected';
      selected.add(key);
    }
    refreshSeat(key);
    updateSidebar();
  }
 
  function removeSeat(key) {
    seatState[key] = 'available';
    selected.delete(key);
    const el = document.querySelector(`[data-key="${key}"]`);
    if (el) {
      el.className = getSeatClass(key);
      el.addEventListener('click', () => toggleSeat(key));
    }
    updateSidebar();
  }
 
  function updateSidebar() {
    let stdCount = 0, vipCount = 0;
    selected.forEach(k => { isVIP(k[0]) ? vipCount++ : stdCount++; });
 
    const takenCount  = Object.values(seatState).filter(s => s === 'taken').length;
    const availCount  = Object.values(seatState).filter(s => s === 'available').length;
 
    document.getElementById('st-avail').textContent = availCount;
    document.getElementById('st-sel').textContent   = selected.size;
    document.getElementById('st-taken').textContent = takenCount;
 
    const pct = Math.round((takenCount / TOTAL_SEATS) * 100);
    document.getElementById('cap-txt').textContent      = pct + '% full';
    document.getElementById('cap-fill').style.width     = pct + '%';
 
    const tagsEl = document.getElementById('sel-tags');
    if (selected.size === 0) {
      tagsEl.innerHTML = '<div class="no-sel">No seats selected yet</div>';
    } else {
      tagsEl.innerHTML = [...selected].sort().map(k => {
        const vip = isVIP(k[0]);
        const label = `${k[0]} · ${k[1]==='L'?'Left':'Right'} ${k.slice(2)}`;
        return `<span class="tag ${vip ? 'tag-vip' : 'tag-std'}">${label}${vip?' ★':''}<button class="tag-rm" onclick="removeSeat('${k}')">×</button></span>`;
      }).join('');
    }
 
    const stdTotal = stdCount * STD_PRICE;
    const vipTotal = vipCount * VIP_PRICE;
    document.getElementById('std-lbl').textContent  = `Standard (${stdCount} × $${STD_PRICE})`;
    document.getElementById('vip-lbl').textContent  = `VIP (${vipCount} × $${VIP_PRICE})`;
    document.getElementById('std-amt').textContent  = '$' + stdTotal.toFixed(2);
    document.getElementById('vip-amt').textContent  = '$' + vipTotal.toFixed(2);
    document.getElementById('total-amt').textContent = '$' + (stdTotal + vipTotal).toFixed(2);
    document.getElementById('book-btn').disabled    = selected.size === 0;
  }
 
  function confirmBooking() {
    if (selected.size === 0) return;
    const booked = [...selected].sort();
    booked.forEach(k => {
      seatState[k] = 'taken';
      selected.delete(k);
      const el = document.querySelector(`[data-key="${k}"]`);
      if (el) {
        el.className = 'seat taken';
        el.replaceWith(el.cloneNode(true));
      }
    });
    updateSidebar();
    const labels = booked.map(k => `${k[0]}·${k[1]==='L'?'L':'R'}${k.slice(2)}`).join(', ');
    showToast(`Booked: ${labels} — enjoy the show!`, true);
  }
 
  function showToast(msg, success) {
    const t = document.getElementById('toast');
    t.textContent = msg;
    t.style.background = success ? '#059669' : '#dc2626';
    t.classList.add('show');
    setTimeout(() => t.classList.remove('show'), 3500);
  }
 
  function pickTime(btn) {
    document.querySelectorAll('.st-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    initSeats();
    buildGrid();
    updateSidebar();
  }
 
  function changeMovie() {
    const idx = parseInt(document.getElementById('movie-sel').value);
    const m = movies[idx];
    document.getElementById('mv-name').textContent = m.name;
    document.getElementById('mv-meta').innerHTML   = m.meta;
    const g = document.getElementById('mv-genre');
    g.textContent = m.genre;
    g.className   = 'badge ' + m.badge;
    initSeats();
    buildGrid();
    updateSidebar();
  }
 
  document.getElementById('date-lbl').textContent = new Date().toLocaleDateString('en-US', {
    weekday: 'long', month: 'short', day: 'numeric'
  });
 
  initSeats();
  buildGrid();
  updateSidebar();