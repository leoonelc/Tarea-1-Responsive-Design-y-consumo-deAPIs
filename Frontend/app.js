// ==========================
// Frontend/app.js (SIGAT FLODECOL) - ÚNICO (COMPLETO)
// ==========================

const API = "http://localhost/sigat_flodecol/Backend/public/index.php";

// ==========================
// HELPERS HTTP
// ==========================
async function apiGet(params = {}) {
  const url = new URL(API);
  Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v));

  const res = await fetch(url.toString(), { method: "GET" });

  const txt = await res.text();
  let data = null;
  try { data = JSON.parse(txt); } catch { data = { ok: false, message: txt }; }

  if (!res.ok) throw new Error("Error GET: " + res.status);
  if (data && data.ok === false) throw new Error(data.message || "Error API");

  return data;
}

async function apiPost(params = {}, formSelector) {
  const url = new URL(API);
  Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v));

  const form = document.querySelector(formSelector);
  if (!form) throw new Error("No se encontró el formulario: " + formSelector);

  const fd = new FormData(form);
  const res = await fetch(url.toString(), { method: "POST", body: fd });

  const txt = await res.text();
  let data = null;
  try { data = JSON.parse(txt); } catch { data = { ok: false, message: txt }; }

  if (!res.ok) throw new Error("Error POST: " + res.status);
  if (data && data.ok === false) throw new Error(data.message || "Error API");

  return data;
}

// ==========================
// FILTRO POR FECHA (SOBRE DATOS, NO DOM)
// ==========================
function filterByDateData(rows, { dateField, fromId, toId }) {
  const from = document.getElementById(fromId)?.value || "";
  const to = document.getElementById(toId)?.value || "";

  const fromDate = from ? new Date(from + "T00:00:00") : null;
  const toDate = to ? new Date(to + "T23:59:59") : null;

  if (!fromDate && !toDate) return rows;

  return rows.filter(r => {
    const raw = (r?.[dateField] || r?.created_at || r?.creado || "").toString();
    if (!raw) return true;

    const onlyDate = raw.slice(0, 10);
    const rowDate = new Date(onlyDate + "T12:00:00");

    if (fromDate && rowDate < fromDate) return false;
    if (toDate && rowDate > toDate) return false;
    return true;
  });
}

// ==========================
// EXPORTAR TABLA A PDF (EXPORTA SOLO FILTRADO)
// ==========================
function exportTableToPDF({
  title,
  subtitle,
  tableSelector,
  fileName,
  orientation = "p",
  responsable = "",
  cargo = "",
  empresa = ""
}) {
  const { jsPDF } = window.jspdf;
  const doc = new jsPDF({ orientation, unit: "pt", format: "a4" });

  let y = 40;

  doc.setFont("helvetica", "bold");
  doc.setFontSize(16);
  doc.text(title || "Reporte", 40, y);
  y += 18;

  doc.setFont("helvetica", "normal");
  doc.setFontSize(11);
  doc.text(subtitle || "", 40, y);
  y += 18;

  doc.setFontSize(10);
  const foot = `${empresa}${responsable ? " • " + responsable : ""}${cargo ? " • " + cargo : ""}`;
  doc.text(foot, 40, y);
  y += 12;

  const table = document.querySelector(tableSelector);
  if (!table) {
    alert("No se encontró la tabla para exportar.");
    return;
  }

  // Head
  const head = [
    Array.from(table.querySelectorAll("thead th"))
      .map(th => th.textContent.trim())
      .filter(h => h.toLowerCase() !== "acciones")
  ];

  // Body: exporta TODO lo filtrado si existe viewData
  const rowsToExport = (PAGER.viewData && Array.isArray(PAGER.viewData))
    ? PAGER.viewData
    : Array.from(table.querySelectorAll("tbody tr"))
      .filter(tr => tr.style.display !== "none")
      .map(tr => Array.from(tr.children).map(td => td.textContent.trim()));

  let body = rowsToExport;

  if (rowsToExport.length && typeof rowsToExport[0] === "object" && !Array.isArray(rowsToExport[0])) {
    body = rowsToExport.map(e => ([
      safe(e.codigo),
      safe(e.departamento || e.depto),
      safe(e.tipo || e.tipo_dispositivo),
      safe(e.nombre_pc || e.nombre_dispositivo),
      safe(e.marca),
      safe(e.modelo),
      safe(e.accesorios),
      safe(e.office || e.licencia_office),
      safe(e.kaspersky || e.licencia_kaspersky),
      safe(e.windows || e.licencia_windows),
      safe(e.estado_equipo),
      safe(e.estado),
      safe(((e.created_at || e.creado || "").toString()).slice(0, 10))
    ]));
  } else {
    body = rowsToExport.map(row => row.slice(0, head[0].length));
  }

  doc.autoTable({
    startY: y + 10,
    head,
    body,
    styles: { fontSize: 8, cellPadding: 4 },
    theme: "grid",
    margin: { left: 20, right: 20 }
  });

  doc.save(fileName || "reporte.pdf");
}

// ==========================
// ✅ PAGINACIÓN + SELECT (10/20/50) + FILTROS + ORDEN
// ==========================
const PAGER = {
  currentPage: 1,
  rowsPerPage: 10,

  data: [],
  viewData: [],

  tableSelector: "#tbl",
  tbody: null,
  pagination: null,
  rowsSelect: null,

  renderRow: null,

  sortKey: null,
  sortDir: 1,
};

function initPager({
  tableSelector = "#tbl",
  rowsSelectId = "rowsPerPage",
  paginationId = "pagination",
  renderRow,
}) {
  PAGER.tableSelector = tableSelector;
  PAGER.tbody = document.querySelector(`${tableSelector} tbody`);
  PAGER.pagination = document.getElementById(paginationId);
  PAGER.rowsSelect = document.getElementById(rowsSelectId);
  PAGER.renderRow = renderRow;

  if (!PAGER.tbody) return;

  if (PAGER.rowsSelect) {
    PAGER.rowsPerPage = parseInt(PAGER.rowsSelect.value || "10", 10);

    // ✅ FIX: al cambiar "Mostrar", renderiza INMEDIATO (sin tocar el botón 1)
    PAGER.rowsSelect.addEventListener("change", () => {
      PAGER.rowsPerPage = parseInt(PAGER.rowsSelect.value || "10", 10);
      PAGER.currentPage = 1;

      applyFiltersAndSort();   // 🔥 CLAVE
      renderSoloPaginacion();  // 🔥 CLAVE
    });
  }

  wireSortingHeaders();
  renderPager();
}

function setPagerData(data = []) {
  PAGER.data = Array.isArray(data) ? data : [];
  PAGER.currentPage = 1;
  applyFiltersAndSort();
  renderSoloPaginacion();
}

function applyFiltersAndSort() {
  let rows = [...PAGER.data];

  const hasFrom = !!document.getElementById("fromDate");
  const hasTo = !!document.getElementById("toDate");
  if (hasFrom || hasTo) {
    rows = filterByDateData(rows, {
      dateField: "created_at",
      fromId: "fromDate",
      toId: "toDate"
    });
  }

  if (PAGER.sortKey) {
    const key = PAGER.sortKey;
    const dir = PAGER.sortDir;

    rows.sort((a, b) => {
      const va = (a?.[key] ?? "").toString().trim().toLowerCase();
      const vb = (b?.[key] ?? "").toString().trim().toLowerCase();
      return va.localeCompare(vb, "es", { numeric: true }) * dir;
    });
  }

  PAGER.viewData = rows;
}

// Render completo (filtros + paginación)
function renderPager() {
  applyFiltersAndSort();
  renderSoloPaginacion();
}

// Render SOLO paginación (sin recalcular filtros/orden a cada click)
function renderSoloPaginacion() {
  if (!PAGER.tbody || typeof PAGER.renderRow !== "function") return;

  const source = (PAGER.viewData && PAGER.viewData.length) ? PAGER.viewData : PAGER.data;

  const total = source.length;
  const per = PAGER.rowsPerPage || 10;
  const totalPages = Math.max(1, Math.ceil(total / per));

  if (PAGER.currentPage > totalPages) PAGER.currentPage = totalPages;

  const start = (PAGER.currentPage - 1) * per;
  const end = start + per;
  const pageData = source.slice(start, end);

  PAGER.tbody.innerHTML = pageData.map(PAGER.renderRow).join("");

  renderPagination(totalPages);
}

function renderPagination(totalPages) {
  if (!PAGER.pagination) return;

  PAGER.pagination.innerHTML = "";

  const mkBtn = (label, disabled, onClick, active = false) => {
    const b = document.createElement("button");
    b.type = "button";
    b.textContent = label;
    b.className = "pager-btn" + (active ? " active" : "");
    b.disabled = disabled;
    b.addEventListener("click", onClick);
    return b;
  };

  // Prev
  PAGER.pagination.appendChild(
    mkBtn("«", PAGER.currentPage === 1, () => {
      PAGER.currentPage--;
      renderSoloPaginacion();
    })
  );

  // Números (ventana)
  const windowSize = 6;
  let start = Math.max(1, PAGER.currentPage - Math.floor(windowSize / 2));
  let end = Math.min(totalPages, start + windowSize - 1);
  start = Math.max(1, end - windowSize + 1);

  for (let i = start; i <= end; i++) {
    PAGER.pagination.appendChild(
      mkBtn(String(i), false, () => {
        PAGER.currentPage = i;
        renderSoloPaginacion();
      }, i === PAGER.currentPage)
    );
  }

  // Next
  PAGER.pagination.appendChild(
    mkBtn("»", PAGER.currentPage === totalPages, () => {
      PAGER.currentPage++;
      renderSoloPaginacion();
    })
  );
}

// ==========================
// ✅ ORDEN POR COLUMNA (SIN DATATABLES)
// ==========================
function wireSortingHeaders() {
  const table = document.querySelector(PAGER.tableSelector);
  if (!table) return;

  const ths = table.querySelectorAll("thead th[data-sort]");
  ths.forEach(th => {
    th.addEventListener("click", () => {
      const key = th.getAttribute("data-sort");
      if (!key) return;

      if (PAGER.sortKey === key) {
        PAGER.sortDir = PAGER.sortDir * -1;
      } else {
        PAGER.sortKey = key;
        PAGER.sortDir = 1;
      }

      // actualizar iconos si existen
      ths.forEach(x => {
        const ico = x.querySelector(".sort-ico");
        if (!ico) return;
        const k = x.getAttribute("data-sort");
        if (k !== PAGER.sortKey) ico.textContent = "⇅";
        else ico.textContent = PAGER.sortDir === 1 ? "▲" : "▼";
      });

      renderPager();
    });
  });
}

// ==========================
// ✅ EJEMPLO: EQUIPOS (tabla #tbl)
// ==========================
async function cargarEquipos() {
  const r = await apiGet({ controller: "equipo", action: "index" });
  const rows = Array.isArray(r) ? r : (r.data || []);
  setPagerData(rows);
}

function safe(v){ return (v ?? "").toString(); }

// Render de fila
function renderEquipoRow(e) {
  return `
    <tr>
      <td>${safe(e.codigo)}</td>
      <td>${safe(e.departamento || e.depto)}</td>
      <td>${safe(e.tipo || e.tipo_dispositivo)}</td>
      <td>${safe(e.nombre_pc || e.nombre_dispositivo)}</td>
      <td>${safe(e.marca)}</td>
      <td>${safe(e.modelo)}</td>
      <td>${safe(e.accesorios)}</td>
      <td>${safe(e.office || e.licencia_office)}</td>
      <td>${safe(e.kaspersky || e.licencia_kaspersky)}</td>
      <td>${safe(e.windows || e.licencia_windows)}</td>
      <td>${safe(e.estado_equipo)}</td>
      <td>${safe(e.estado)}</td>
      <td>${safe((e.created_at || e.creado || "").toString()).slice(0,10)}</td>
      <td class="td-actions">
        <button class="btn btn-sm btn-primary" onclick='window.verDetalles && verDetalles(${JSON.stringify(e)})'>Ver</button>
        <button class="btn btn-sm btn-primary" onclick='window.editar && editar(${JSON.stringify(e)})'>Editar</button>
        <button class="btn btn-sm btn-danger" onclick="window.eliminar && eliminar(${safe(e.id)})">Eliminar</button>
      </td>
    </tr>
  `;
}

// ==========================
// ✅ EXPORTAR PDF (Equipos)
// ==========================
function exportarPDF() {
  exportTableToPDF({
    title: "Equipos",
    subtitle: "SIGAT FLODECOL • Inventario • CRUD + PDF",
    tableSelector: "#tbl",
    fileName: "equipos.pdf",
    orientation: "l",
    empresa: "FLODECOL S.A."
  });
}

// ==========================
// ✅ HOOK FILTRO FECHA (si tienes inputs #fromDate #toDate)
// ==========================
function wireDateFilter() {
  const from = document.getElementById("fromDate");
  const to = document.getElementById("toDate");
  if (!from && !to) return;

  const onChange = () => {
    PAGER.currentPage = 1;
    renderPager();
  };

  if (from) from.addEventListener("change", onChange);
  if (to) to.addEventListener("change", onChange);
}

// ==========================
// INIT POR PÁGINA
// ==========================
document.addEventListener("DOMContentLoaded", async () => {
  const tbl = document.querySelector("#tbl");
  if (!tbl) return;

  initPager({
    tableSelector: "#tbl",
    rowsSelectId: "rowsPerPage",
    paginationId: "pagination",
    renderRow: renderEquipoRow,
  });

  wireDateFilter();

  try {
    await cargarEquipos();
  } catch (e) {
    console.error(e);
    alert("No se pudo cargar equipos:\n" + e.message);
  }
});
