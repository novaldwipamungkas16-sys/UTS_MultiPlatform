from pathlib import Path
from io import BytesIO
from docx import Document
from docx.shared import Cm, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH as A
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
import json

root=Path('D:/KULIAH_UIN_MALANG/SMT 5/OPT MULTIPLATFORM/UTS')
ref=Document('D:/KULIAH_UIN_MALANG/SMT 5/MOBILE PROGRAMING PRAK/LAPRAK/LAPRAK 11.docx')
d=Document()
s=d.sections[0]
s.page_width=Cm(21); s.page_height=Cm(29.7)
s.top_margin=Cm(2.54); s.bottom_margin=Cm(2.54); s.left_margin=Cm(3.17); s.right_margin=Cm(3.17)
for name in ['Normal','Heading 1','Heading 2']:
 st=d.styles[name]; st.font.name='Times New Roman'; st.font.size=Pt(12)
 st._element.get_or_add_rPr().rFonts.set(qn('w:eastAsia'),'Times New Roman')
 st.paragraph_format.line_spacing=1.5; st.paragraph_format.space_after=Pt(6)
 st.paragraph_format.first_line_indent=Cm(0)
 st.paragraph_format.alignment=A.JUSTIFY
 if name.startswith('Heading'):
  st.font.bold=True; st.font.color.rgb=None; st.paragraph_format.keep_with_next=True

def para(t='',bold=False,align=A.JUSTIFY):
 p=d.add_paragraph(); p.alignment=align; r=p.add_run(t); r.bold=bold; return p

def heading(t):
 return d.add_paragraph(t,'Heading 1')

def sub(t):
 return d.add_paragraph(t,'Heading 2')

para('LAPORAN UJIAN TENGAH SEMESTER\nPEMROGRAMAN MULTIPLATFORM',True,A.CENTER)
para('(Pengembangan Aplikasi FinTrack dengan Asynchronous Programming dan Data Persistence)',True,A.CENTER)
para()
# Gunakan logo dari cover contoh, bukan screenshot atau materi praktikum lain.
shape=ref.inline_shapes[0]
rid=shape._inline.graphic.graphicData.pic.blipFill.blip.embed
logo=ref.part.related_parts[rid].blob
p=para(align=A.CENTER); p.add_run().add_picture(BytesIO(logo),width=Cm(4.5))
para()
for t in ['Nama\t: Noval Dwi Pamungkas','NIM\t: 240605110040','Kelas\t: A — Semester 5',"Dosen\t: A’la Syauqi, M.Kom"]:
 p=para(t,align=A.LEFT); p.paragraph_format.tab_stops.add_tab_stop(Cm(2))
para()
for t in ['JURUSAN TEKNIK INFORMATIKA','FAKULTAS SAINS DAN TEKNOLOGI','UNIVERSITAS ISLAM NEGERI MAULANA MALIK IBRAHIM MALANG','GANJIL 2026/2027']:
 p=para(t,True,A.CENTER); p.paragraph_format.space_after=Pt(0)
d.add_page_break()
heading('1. TUJUAN')
for t in ['Mengembangkan aplikasi pencatatan keuangan pribadi menggunakan Flutter dan Dart.','Menerapkan pemrograman asinkron melalui Future, async, await, Future.wait, dan Future.delayed.','Menerapkan penyimpanan transaksi menggunakan SQLite dan preferensi pengguna menggunakan SharedPreferences.','Menguji kode aplikasi melalui analisis statis, pengujian otomatis, dan pembuatan APK Android.']:
 p=para(t); p.style='List Bullet'; p.paragraph_format.line_spacing=1.5
heading('2. LANGKAH KERJA SINGKAT')
steps=[
('Menyiapkan struktur proyek.','Proyek fintrack_app dipisahkan menjadi folder models, services, screens, dan widgets. Pemisahan ini memudahkan pengelolaan model data, akses penyimpanan, antarmuka, dan komponen yang digunakan kembali.'),
('Membuat model transaksi.','TransactionModel merepresentasikan data transaksi yang meliputi id, title, amount, type, category, date, dan note. Konversi data dilakukan melalui bentuk Map agar dapat disimpan dan dibaca dari SQLite.'),
('Menerapkan penyimpanan SQLite.','DatabaseHelper membuka fintrack.db dan membuat tabel transactions. Operasi insertTransaction, getAllTransactions, updateTransaction, dan deleteTransaction digunakan untuk menambah, membaca, mengubah, dan menghapus transaksi.'),
('Menerapkan preferensi pengguna.','PreferenceService menangani penyimpanan tema, nama pengguna, dan anggaran bulanan melalui SharedPreferences. Data preferensi dipisahkan dari data transaksi karena kebutuhan dan strukturnya berbeda.'),
('Membangun halaman aplikasi.','Halaman dashboard menampilkan ringkasan keuangan dan daftar transaksi. Form transaksi digunakan untuk pengisian data. Halaman statistik menampilkan agregasi kategori, sedangkan halaman pengaturan mengelola preferensi.'),
('Mengelola proses asinkron.','Operasi penyimpanan dijalankan menggunakan async dan await. Future.wait digunakan untuk memuat beberapa data awal, sedangkan QuoteService mensimulasikan pemuatan tips finansial menggunakan Future.delayed.'),
('Menjalankan pemeriksaan proyek.','Pemeriksaan dilakukan dengan flutter analyze, flutter test, dan flutter build apk --debug. Hasil pengujian dicatat pada bagian hasil dan pembahasan; hasil build tidak disamakan dengan bukti pengujian UI pada emulator.')]
for i,(title,text) in enumerate(steps,1):
 p=para(); p.add_run(f'{i}. {title} ').bold=True; p.add_run(text)
heading('3. HASIL DAN PEMBAHASAN')
sub('3.1 Gambaran Aplikasi')
para('FinTrack membantu pengguna mencatat pemasukan dan pengeluaran, melihat saldo bersih, serta mengevaluasi pengeluaran berdasarkan kategori. Data transaksi disimpan secara lokal sehingga fitur pencatatan tidak memerlukan layanan backend. Antarmuka menyediakan pencarian, filter transaksi, pengaturan anggaran, dan pilihan tema terang atau gelap.')
sub('3.2 Implementasi Asynchronous Programming')
para('Operasi database dan preferensi mengembalikan Future dan ditunggu menggunakan await. Pada pemuatan awal, Future.wait digunakan untuk menunggu beberapa proses pemuatan data. QuoteService memakai penundaan 800 milidetik sebagai simulasi pengambilan tips finansial, bukan sebagai integrasi API eksternal.')
sub('3.3 Implementasi Data Persistence')
para('SQLite menyimpan transaksi pada tabel transactions. Pencarian menggunakan parameter whereArgs, sedangkan getSummaryTotals menghitung total pemasukan, pengeluaran, dan saldo. getCategoryBreakdown mengelompokkan nominal berdasarkan kategori. SharedPreferences menyimpan is_dark_mode, user_name, dan monthly_budget untuk mempertahankan preferensi pengguna.')
sub('3.4 Hasil Pengujian Kode')
para('Pada pengujian sebelumnya dalam sesi pengerjaan ini, flutter test menyelesaikan 10 pengujian dan pembuatan APK debug berhasil. Hasil ini menunjukkan keberhasilan pemeriksaan otomatis dan proses build, tetapi tidak menjadi bukti bahwa seluruh interaksi antarmuka telah diuji pada Pixel 5.')
t=d.add_table(rows=1,cols=2); t.style='Table Grid'
for c,text in zip(t.rows[0].cells,['Pemeriksaan','Hasil yang tercatat']): c.text=text
for a,b in [('flutter analyze','Dilaporkan selesai tanpa masalah pada pengujian sebelumnya.'),('flutter test','10 pengujian berhasil (All tests passed!).'),('flutter build apk --debug','APK berhasil dibuat pada build/app/outputs/flutter-apk/app-debug.apk.'),('Emulator Pixel 5','AVD ditemukan di D:/AndroidAVD/avd, tetapi proses sebelumnya belum mencapai status device pada ADB. Pengujian UI baru belum terverifikasi.')]:
 cells=t.add_row().cells; cells[0].text=a; cells[1].text=b
sub('3.5 Screenshot Implementasi')
para('Gambar berikut berasal dari folder screenshots proyek FinTrack yang sudah tersedia. Gambar digunakan untuk menjelaskan halaman aplikasi, bukan sebagai bukti screenshot baru dari pengujian Pixel 5. Setiap pasangan disusun berdampingan dengan skala proporsional agar ruang halaman digunakan secara efisien.')
imgs=[('01_dashboard_light.png','Gambar 1. Dashboard mode terang.'),('02_dashboard_dark.png','Gambar 2. Dashboard mode gelap.'),('03_form_tambah_transaksi.png','Gambar 3. Form tambah transaksi.'),('04_statistik_kategori.png','Gambar 4. Statistik kategori.'),('05_pengaturan_preferensi.png','Gambar 5. Pengaturan preferensi.')]
for start in range(0,len(imgs),2):
 table=d.add_table(rows=1,cols=2); table.alignment=WD_TABLE_ALIGNMENT.CENTER; table.autofit=False
 for c in table.columns: c.width=Cm(7.33)
 trpr=table.rows[0]._tr.get_or_add_trPr(); trpr.append(OxmlElement('w:cantSplit'))
 borders=OxmlElement('w:tblBorders')
 for side in ['top','left','bottom','right','insideH','insideV']:
  e=OxmlElement('w:'+side); e.set(qn('w:val'),'nil'); borders.append(e)
 table._tbl.tblPr.append(borders)
 for cell,(fn,cap) in zip(table.rows[0].cells,imgs[start:start+2]):
  cell.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.TOP
  p=cell.paragraphs[0]; p.alignment=A.CENTER; p.paragraph_format.line_spacing=1; p.paragraph_format.space_after=Pt(4)
  p.add_run().add_picture(str(root/'fintrack_app/screenshots'/fn),width=Cm(5.1))
  p=cell.add_paragraph(cap); p.alignment=A.CENTER; p.paragraph_format.line_spacing=1; p.paragraph_format.space_after=Pt(4)
  for r in p.runs: r.font.size=Pt(10)
 p=para(); p.paragraph_format.space_after=Pt(0); p.paragraph_format.line_spacing=1; p.paragraph_format.keep_with_next=False
para('Dashboard menampilkan kondisi keuangan dalam dua tema. Form transaksi menyediakan pengisian data transaksi. Halaman statistik merangkum data per kategori, sedangkan pengaturan menyediakan pengelolaan preferensi. Dokumentasi ini melengkapi pembahasan antarmuka tanpa menggantikan pengujian interaktif pada perangkat.')
heading('4. KESIMPULAN')
para('FinTrack menerapkan pemrograman asinkron dan penyimpanan lokal dalam aplikasi pencatatan keuangan berbasis Flutter. SQLite digunakan untuk transaksi terstruktur, sedangkan SharedPreferences digunakan untuk preferensi sederhana. Pengujian otomatis menyelesaikan 10 pengujian dan APK debug berhasil dibuat. Pengujian antarmuka serta pengambilan screenshot baru pada emulator Pixel 5 masih perlu diverifikasi karena emulator pada percobaan sebelumnya belum terhubung ke ADB.')
# Nomor halaman, tanpa mengandalkan hasil render Word.
f=s.footer.paragraphs[0]; f.alignment=A.CENTER
fld=OxmlElement('w:fldSimple'); fld.set(qn('w:instr'),'PAGE'); f._p.append(fld)
out=root/'Laporan_UTS_FinTrack_Noval_240605110040_Revisi_Format.docx'
d.save(out)
# Verifikasi struktur dan ukuran gambar langsung dari paket tersimpan.
v=Document(out)
alltext='\n'.join(p.text for p in v.paragraphs)
assert all(x in alltext for x in ['1. TUJUAN','2. LANGKAH KERJA SINGKAT','3. HASIL DAN PEMBAHASAN','4. KESIMPULAN','Pixel 5','10 pengujian'])
assert not any(x in alltext for x in ['Tasbih','GetX','game_app'])
image_tables=[t for t in v.tables if t._tbl.xpath('.//w:drawing')]
assert len(image_tables)==3
assert [len(t._tbl.xpath('.//w:drawing')) for t in image_tables]==[2,2,1]
assert len(v.inline_shapes)==6
print(json.dumps({'output':str(out),'bytes':out.stat().st_size,'image_grid':[2,2,1],'images_with_logo':len(v.inline_shapes),'page_cm':[v.sections[0].page_width.cm,v.sections[0].page_height.cm],'screenshot_width_cm':5.1,'verified':True},indent=2))
