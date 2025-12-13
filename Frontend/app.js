const API = "../Backend/public/index.php";

async function apiGet(params) {
  const url = API + "?" + new URLSearchParams(params).toString();
  const res = await fetch(url);
  return res.json();
}

async function apiPost(params, formSelector = "form") {
  const form = document.querySelector(formSelector);
  const res = await fetch(API + "?" + new URLSearchParams(params).toString(), {
    method: "POST",
    body: new FormData(form)
  });
  return res.json();
}

/* ===========================
   EXPORT PDF EMPRESARIAL
   LOGO + FIRMA + RESPONSABLE
=========================== */
async function exportTableToPDF({
  title = "Reporte",
  subtitle = "",
  tableSelector = "#tbl",
  fileName = "reporte.pdf",
  orientation = "p",
  responsable = "Ing. Jhoe Cadena",
  cargo = "Responsable de Sistemas",
  empresa = "InventarioEquiposTI",
  logoPath = "logo.png"
}) {
  const table = document.querySelector(tableSelector);
  if (!table) {
    alert("No se encontró la tabla para exportar.");
    return;
  }

  // tomar headers y body, pero ignorar columna de Acciones
  const headTh = Array.from(table.querySelectorAll("thead th"));
  const head = headTh
    .map(th => th.innerText.trim())
    .filter(h => h.toLowerCase() !== "acciones");

  const rows = Array.from(table.querySelectorAll("tbody tr"))
    .filter(tr => tr.style.display !== "none");

  const body = rows.map(tr => {
    const tds = Array.from(tr.querySelectorAll("td"));
    // quitar última celda si es acciones (por si existe)
    const clean = tds.map(td => td.innerText.trim());
    if (headTh.length === clean.length && headTh[headTh.length - 1].innerText.trim().toLowerCase() === "acciones") {
      clean.pop();
    }
    return clean;
  });

  const { jsPDF } = window.jspdf;
  const doc = new jsPDF({ orientation, unit: "pt", format: "a4" });

  const pageWidth = doc.internal.pageSize.getWidth();
  const pageHeight = doc.internal.pageSize.getHeight();

  // colores corporativos
  const primary = [40, 64, 135];
  const gray = [90, 90, 90];
  const light = [245, 247, 250];

  // header
  doc.setFillColor(...primary);
  doc.rect(0, 0, pageWidth, 90, "F");

  // logo
  try {
    const logo = new Image();
    logo.src = logoPath;
    await new Promise((resolve, reject) => {
      logo.onload = resolve;
      logo.onerror = reject;
    });
    doc.addImage(logo, "PNG", 40, 20, 50, 50);
  } catch {
    // si no hay logo, no rompe el PDF
  }

  doc.setTextColor(255, 255, 255);
  doc.setFont("helvetica", "bold");
  doc.setFontSize(18);
  doc.text(empresa, 100, 40);

  doc.setFontSize(11);
  doc.setFont("helvetica", "normal");
  doc.text("Sistema de Control de Equipos de Cómputo", 100, 60);

  // títulos
  doc.setTextColor(...gray);
  doc.setFont("helvetica", "bold");
  doc.setFontSize(15);
  doc.text(title, 40, 125);

  doc.setFont("helvetica", "normal");
  doc.setFontSize(10);
  doc.text(subtitle || "Reporte generado desde el sistema", 40, 145);

  doc.text(
    "Fecha de generación: " + new Date().toLocaleString(),
    pageWidth - 240,
    145
  );

  // tabla
  doc.autoTable({
    startY: 165,
    head: [head],
    body,
    theme: "grid",
    styles: {
      font: "helvetica",
      fontSize: 9,
      cellPadding: 6,
      textColor: [60, 60, 60]
    },
    headStyles: {
      fillColor: primary,
      textColor: [255, 255, 255],
      halign: "center"
    },
    alternateRowStyles: { fillColor: light },
    margin: { left: 40, right: 40 }
  });

  // firma
  const y = (doc.lastAutoTable?.finalY ?? 200) + 55;

  doc.setDrawColor(120);
  doc.line(40, y, 260, y);

  doc.setFont("helvetica", "bold");
  doc.setTextColor(60, 60, 60);
  doc.text(responsable, 40, y + 15);

  doc.setFont("helvetica", "normal");
  doc.text(cargo, 40, y + 30);
  doc.text(empresa, 40, y + 45);

  // pie paginado
  const total = doc.internal.getNumberOfPages();
  for (let i = 1; i <= total; i++) {
    doc.setPage(i);
    doc.setFontSize(9);
    doc.setTextColor(120);
    doc.text(`Página ${i} de ${total}`, pageWidth - 100, pageHeight - 30);
    doc.text(`${empresa} • Uso interno`, 40, pageHeight - 30);
  }

  doc.save(fileName);
}

/* ===== filtro por fecha en una columna específica (YYYY-MM-DD) ===== */
function filterTableByDate({
  tableSelector = "#tbl",
  dateColIndex = 1,  // 0 primera col, 1 segunda, etc.
  fromId = "fDesde",
  toId = "fHasta"
}) {
  const desde = document.getElementById(fromId)?.value;
  const hasta = document.getElementById(toId)?.value;
  if (!desde || !hasta) return;

  const rows = document.querySelectorAll(`${tableSelector} tbody tr`);
  rows.forEach(tr => {
    const fecha = tr.children[dateColIndex]?.innerText?.trim();
    tr.style.display = (fecha >= desde && fecha <= hasta) ? "" : "none";
  });
}
