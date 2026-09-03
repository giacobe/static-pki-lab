# Grading Rubrics

These rubrics score the PKI Environment Build precursor and the Three-VM
Public-Key Infrastructure Lab independently. Each lab is worth 50 points.

For both labs, **Evidence** points measure whether the required result is
present in a readable, annotated screenshot. **Qualitative** points measure
the accuracy and depth of annotations, written answers, interpretation of
results, and explanations of unexpected behavior. Each rubric assigns 20 of
50 points (40%) to qualitative assessment.

## Common evidence standard

Award full Evidence credit when the screenshot:

- is readable and shows the relevant VM, command, setting, or browser result;
- includes an annotation identifying the specific fact being graded;
- shows the student's personalized hostname or user ID when applicable; and
- does not expose a password, passphrase, private key, or private-key content.

Award half Evidence credit when the result appears correct but the image is
unannotated, difficult to read, missing role or hostname context, or requires
the grader to infer the claimed result. Award no Evidence credit when the
result is absent, contradictory, unverifiable, or belongs to the wrong role.
Round half points to the nearest 0.5 point.

One screenshot per numbered section is sufficient when it captures all
required facts legibly. Do not deduct merely because a student uses multiple
screenshots for a section.

## Common qualitative standard

For written answers and interpretive annotations:

- **Full credit:** technically accurate, specific to the observed result, and
  explains why the result matters.
- **Half credit:** substantially correct but incomplete, generic, or weakly
  connected to the submitted evidence.
- **No credit:** omitted, materially incorrect, or contradicted by the
  evidence.

A command transcript without interpretation does not earn Qualitative credit.

# Rubric 1: PKI Environment Build Precursor - 50 points

| Section | Evidence: required result | Evidence | Qualitative assessment | Qualitative | Total |
|---|---|---:|---|---:|---:|
| 1. Obtain the software | VMware version, correct Ubuntu architecture, and verified ISO digest | 2 | Answers both questions: why the published hash is meaningful and why the selected guest architecture is correct | 3 | 5 |
| 2. CA VM | `pki-ca` running Ubuntu 24.04 with the assigned resources, NAT connectivity, Git clone, and active SSH | 3 | Annotation correctly identifies the role, architecture, NAT address/default route, and repository verification | 1 | 4 |
| 3. Web-server VM | `pki-server` running Ubuntu 24.04 with Apache active, repository cloned, and HTTP responding locally | 3 | Annotation distinguishes the HTTP service from HTTPS and identifies the relevant service result | 1 | 4 |
| 4. Client VM | `pki-client` running Ubuntu Desktop 24.04 with Firefox, NAT connectivity, and the repository cloned | 3 | Annotation identifies the client role, architecture, and successful Internet/package-installation path | 1 | 4 |
| 5. Isolated VMware network | Correct Workstation LAN Segment or Fusion custom network named `PKI-LAB` | 3 | Annotation explains or identifies the settings that prevent host, DHCP, NAT, and physical-network access | 1 | 4 |
| 6. Second adapters | Each VM has one NAT adapter and one adapter attached to `PKI-LAB` | 3 | Annotation clearly maps Adapter 1 and Adapter 2 to their distinct purposes | 1 | 4 |
| 7. Static lab addresses | Correct `.10`, `.20`, and `.30` addresses, name resolution, and no lab-interface gateway | 3 | Annotation interprets interfaces and routes rather than merely circling command output | 2 | 5 |
| 8. Dual-network verification | Peer connectivity and Internet access both succeed over the appropriate adapters | 2 | Answers all three routing questions accurately, including why the lab interface has no default gateway | 4 | 6 |
| 9. Personalized HTTP site | Apache serves the student-ID page on TCP 80 and has no HTTPS listener | 3 | Annotation identifies the personalized document root, successful HTTP result, and absence of port 443 | 1 | 4 |
| 10. Client HTTP test | Firefox or `curl` shows `http://<userid>.psu.edu` and the personalized page; HTTPS fails | 2 | Answers all three role/confidentiality questions and correctly distinguishes name resolution, content serving, and lack of transport protection | 4 | 6 |
| 11. Final readiness | Passing role-appropriate precursor preflight and completed readiness checklist | 3 | Annotation identifies any resolved warning or confirms why the displayed checks establish readiness | 1 | 4 |
| **Total** |  | **30** |  | **20** | **50** |

### Precursor scoring notes

- Section 1 requires evidence for only the student's applicable host platform.
- Sections 2-4 may use a single composite screenshot per section if the text
  remains readable.
- For Section 8, suggested question weights are 1 point for each adapter
  selection and 2 points for explaining the omitted default gateway.
- For Section 10, suggested question weights are 1 point each for identifying
  the resolver and web server and 2 points for the confidentiality explanation.

# Rubric 2: Three-VM Public-Key Infrastructure Lab - 50 points

| Section | Evidence: required result | Evidence | Qualitative assessment | Qualitative | Total |
|---|---|---:|---|---:|---:|
| 1. Server key and CSR | Personalized CN and SAN, valid CSR signature, and protected server key without exposing private material | 5 | Annotation explains the identity asserted by the CSR and demonstrates correct private-key custody | 2 | 7 |
| 2. Certificate authority | CA database structure, protected CA key, and inspected self-signed root certificate | 4 | Answers all four questions about self-signing, CA authorization, Key Usage, and public-certificate/private-key custody | 6 | 10 |
| 3. Review and issue | CSR reviewed on the CA, controlled SAN extension used, certificate issued, and CA database updated | 5 | Answers all three questions about serial/database linkage, critical `CA:FALSE`, and CA control of requested extensions | 5 | 10 |
| 4. Retrieve and verify | Server retrieves only public certificates and verifies chain, hostname, and public-key match | 4 | Annotation explains what the verification results prove and identifies that no private key crossed machines | 1 | 5 |
| 5. Deploy HTTPS | Apache configuration passes, TCP 443 is listening, and the personalized site is served over HTTPS | 5 | Annotation connects the configured certificate, retained server key, hostname, and successful service result | 1 | 6 |
| 6. Client trust | Failure before trust, success with explicit CA trust, Firefox success after import, and rejection after trust removal | 4 | Annotation accurately distinguishes application-specific trust, browser trust, and server identity | 2 | 6 |
| 7. Validation boundaries | Correct outcomes for IP address, unlisted hostname, validity dates, and trust removal; matrix completed | 3 | Explanations distinguish issuer trust, SAN authorization, validity, and proof of private-key possession | 2 | 5 |
| Final reflection | Evidence is scored in the sections above | 0 | Explains why private-key custody, CA signature, authorized SAN, validity, and client trust are all jointly required | 1 | 1 |
| **Total** |  | **30** |  | **20** | **50** |

### PKI scoring notes

- For Section 2's 6 qualitative points, award 1 point for each of the first
  three answers and 3 points for the public-certificate/private-key custody
  explanation.
- For Section 3's 5 qualitative points, award 1 point for serial/database
  linkage, 2 points for `CA:FALSE`, and 2 points for controlled SAN issuance.
- The Section 7 matrix earns Evidence credit only when its observed outcomes
  agree with the accompanying screenshots or command output.
- If a student exposes private-key contents or a passphrase, award no Evidence
  credit for that screenshot and follow the course's credential-exposure and
  resubmission policy. Do not redistribute the image.

## Optional overall adjustments

Apply these only after scoring the section tables:

- Deduct up to 2 points for a report that is substantially disorganized or
  repeatedly fails to associate evidence with numbered sections.
- Do not deduct twice for the same missing result. If a failed prerequisite
  causes several later checks to fail, score each required result as shown but
  apply no additional global penalty.
- A technically valid alternative command or interface may receive full
  credit when the student documents it and demonstrates the same security
  property.
