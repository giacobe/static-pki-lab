import fs from "node:fs/promises";
import path from "node:path";
import { Workbook } from "@oai/artifact-tool";

const outputDir = path.resolve("output/canvas");
const previewDir = path.resolve("tmp/canvas-rubric-previews");

const headers = [
  "Rubric Name",
  "Criteria Name",
  "Criteria Description",
  "Criteria Enable Range",
  "Rating Name",
  "Rating Description",
  "Rating Points",
  "Rating Name",
  "Rating Description",
  "Rating Points",
  "Rating Name",
  "Rating Description",
  "Rating Points",
];

const precursor = [
  ["E1 Evidence - Software and ISO", 2, "Readable annotated evidence shows the VMware version, correct Ubuntu architecture, and matching published ISO digest."],
  ["Q1 Qualitative - Hash and architecture", 3, "Answers explain why a published hash provides assurance and why the selected guest architecture is correct."],
  ["E2 Evidence - CA VM", 3, "Annotated evidence shows pki-ca on Ubuntu 24.04 with assigned resources, NAT connectivity, active SSH, and the repository cloned."],
  ["Q2 Qualitative - CA VM interpretation", 1, "Annotation correctly identifies the role, architecture, NAT address or default route, and repository verification."],
  ["E3 Evidence - Web-server VM", 3, "Annotated evidence shows pki-server on Ubuntu 24.04 with Apache active, HTTP responding locally, and the repository cloned."],
  ["Q3 Qualitative - HTTP interpretation", 1, "Annotation distinguishes the working HTTP service from HTTPS and identifies the relevant service result."],
  ["E4 Evidence - Client VM", 3, "Annotated evidence shows pki-client on Ubuntu Desktop 24.04 with Firefox, NAT connectivity, and the repository cloned."],
  ["Q4 Qualitative - Client interpretation", 1, "Annotation identifies the client role, architecture, and successful Internet or package-installation path."],
  ["E5 Evidence - Isolated network", 3, "Annotated evidence shows the correct Workstation LAN Segment or Fusion custom PKI-LAB network."],
  ["Q5 Qualitative - Isolation properties", 1, "Annotation identifies the settings that prevent host, DHCP, NAT, and physical-network access."],
  ["E6 Evidence - Second adapters", 3, "Annotated evidence shows each VM with one NAT adapter and one adapter attached to PKI-LAB."],
  ["Q6 Qualitative - Adapter purposes", 1, "Annotation clearly maps Adapter 1 and Adapter 2 to their distinct purposes."],
  ["E7 Evidence - Static addressing", 3, "Annotated evidence shows .10, .20, and .30 addresses, correct name resolution, and no lab-interface gateway."],
  ["Q7 Qualitative - Interface and route analysis", 2, "Annotation accurately interprets the interfaces and routing output rather than merely marking command text."],
  ["E8 Evidence - Dual-network operation", 2, "Annotated evidence shows peer connectivity and Internet access succeeding over the appropriate adapters."],
  ["Q8 Qualitative - Routing answers", 4, "Answers identify the adapter used for lab and Internet traffic and explain why the lab interface omits a default gateway."],
  ["E9 Evidence - Personalized HTTP site", 3, "Annotated evidence shows Apache serving the student-ID page on TCP 80 with no HTTPS listener."],
  ["Q9 Qualitative - HTTP evidence interpretation", 1, "Annotation identifies the personalized document root, successful HTTP result, and absence of port 443."],
  ["E10 Evidence - Client HTTP test", 2, "Annotated evidence shows the personalized HTTP page from the client and the expected HTTPS failure."],
  ["Q10 Qualitative - Roles and confidentiality", 4, "Answers distinguish name resolution from content serving and explain why plain HTTP is unsuitable for confidential data."],
  ["E11 Evidence - Final readiness", 3, "Annotated evidence shows the role-appropriate precursor preflight passing and the readiness checklist completed."],
  ["Q11 Qualitative - Readiness interpretation", 1, "Annotation explains a resolved warning or why the displayed checks establish readiness for the PKI lab."],
];

const pki = [
  ["E1 Evidence - Server key and CSR", 5, "Annotated evidence shows the personalized CN and SAN, a valid CSR signature, and protected server-key permissions without exposing private material."],
  ["Q1 Qualitative - CSR identity and custody", 2, "Annotation explains the identity asserted by the CSR and demonstrates correct private-key custody."],
  ["E2 Evidence - Certificate authority", 4, "Annotated evidence shows the CA database structure, protected CA key, and inspected self-signed root certificate."],
  ["Q2 Qualitative - Root CA answers", 6, "Answers accurately address self-signing fields, CA authorization, Key Usage, and public-certificate versus private-key custody."],
  ["E3 Evidence - Review and issue", 5, "Annotated evidence shows CSR review on the CA, controlled SAN issuance, the issued certificate, and updated CA database."],
  ["Q3 Qualitative - Issuance answers", 5, "Answers explain serial and database linkage, critical CA:FALSE, and why the CA controls requested extensions."],
  ["E4 Evidence - Retrieve and verify", 4, "Annotated evidence shows retrieval of public certificates and successful chain, hostname, and public-key-match verification."],
  ["Q4 Qualitative - Verification meaning", 1, "Annotation explains what the verification proves and identifies that no private key crossed machines."],
  ["E5 Evidence - Deploy HTTPS", 5, "Annotated evidence shows a valid Apache configuration, TCP 443 listening, and the personalized site served over HTTPS."],
  ["Q5 Qualitative - HTTPS components", 1, "Annotation connects the configured certificate, retained server key, hostname, and successful service result."],
  ["E6 Evidence - Client trust", 4, "Annotated evidence shows failure before trust, success with explicit trust, Firefox success after import, and rejection after removal."],
  ["Q6 Qualitative - Trust interpretation", 2, "Annotation distinguishes application-specific trust, browser trust, and server identity."],
  ["E7 Evidence - Validation boundaries", 3, "Annotated evidence and the completed matrix show correct results for IP address, unlisted hostname, validity, and trust removal."],
  ["Q7 Qualitative - Validation analysis", 2, "Explanations distinguish issuer trust, SAN authorization, validity, and proof of private-key possession."],
  ["Q8 Qualitative - Final reflection", 1, "Reflection explains why private-key custody, CA signature, authorized SAN, validity, and client trust are jointly required."],
];

function csvCell(value) {
  const text = String(value);
  return /[",\r\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

function createCsv(rubricName, criteria) {
  const rows = criteria.map(([name, points, description]) => {
    const partial = points / 2;
    const evidence = name.startsWith("E");
    return [
      rubricName,
      name,
      description,
      false,
      evidence ? "Complete" : "Full credit",
      evidence
        ? "Required result is present, readable, correctly annotated, and attributable to the proper VM or role."
        : "Response is technically accurate, specific to the observed result, and explains why it matters.",
      points,
      "Partial",
      evidence
        ? "Result appears substantially correct but is incomplete, weakly annotated, difficult to read, or missing context."
        : "Response is substantially correct but incomplete, generic, or weakly connected to the submitted evidence.",
      partial,
      "Missing or incorrect",
      evidence
        ? "Result is absent, contradictory, unverifiable, unsafe, or belongs to the wrong role."
        : "Response is omitted, materially incorrect, or contradicted by the evidence.",
      0,
    ];
  });
  return [headers, ...rows].map((row) => row.map(csvCell).join(",")).join("\r\n") + "\r\n";
}

async function writeAndVerify(filename, rubricName, criteria) {
  const csvText = createCsv(rubricName, criteria);
  const workbook = await Workbook.fromCSV(csvText, { sheetName: "Canvas Rubric" });
  const sheet = workbook.worksheets.getItem("Canvas Rubric");
  sheet.getRange("A1:M1").format = {
    fill: "#1F4E78",
    font: { bold: true, color: "#FFFFFF" },
    wrapText: true,
  };
  sheet.getRange(`A1:M${criteria.length + 1}`).format.wrapText = true;
  sheet.freezePanes.freezeRows(1);
  const inspection = await workbook.inspect({
    kind: "table",
    range: `Canvas Rubric!A1:M${criteria.length + 1}`,
    include: "values",
    tableMaxRows: criteria.length + 1,
    tableMaxCols: 13,
    maxChars: 3000,
  });
  const importedName = sheet.getRange("A2").values[0][0];
  if (importedName !== rubricName || !inspection.ndjson) {
    throw new Error(`Artifact validation failed for ${filename}`);
  }
  const preview = await workbook.render({
    sheetName: "Canvas Rubric",
    range: `A1:M${Math.min(criteria.length + 1, 8)}`,
    scale: 1,
    format: "png",
  });
  await fs.writeFile(
    path.join(previewDir, `${filename}.png`),
    new Uint8Array(await preview.arrayBuffer()),
  );
  await fs.writeFile(path.join(outputDir, filename), csvText, "utf8");
}

await fs.mkdir(outputDir, { recursive: true });
await fs.mkdir(previewDir, { recursive: true });

await writeAndVerify(
  "PKI-Environment-Precursor-Canvas-Rubric.csv",
  "PKI Environment Build Precursor - 50 Points",
  precursor,
);
await writeAndVerify(
  "Three-VM-PKI-Lab-Canvas-Rubric.csv",
  "Three-VM Public-Key Infrastructure Lab - 50 Points",
  pki,
);

console.log("Canvas rubric CSV files created and artifact-validated.");
