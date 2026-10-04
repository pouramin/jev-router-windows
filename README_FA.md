<div dir="rtl" align="right">

# Jev Router for Windows

**فارسی** · [English](README_EN.md) · [صفحه اصلی](README.md)

## این پروژه چیه؟

پروژه‌ی **Jev Router for Windows** یک برنامه‌ی گرافیکی برای راه‌اندازی و مدیریت اتصال **TypeSafe Jev** به ابزارهای Coding Agent روی Windows است؛ هدف اینه که کاربر عادی مجبور نباشه با PowerShell، فایل‌های config، متغیرهای محیطی و نصب دستی packageها درگیر بشه.

نسخه‌ی فعلی روی 2 مسیر تمرکز داره:

- برای **Codex Desktop / Codex CLI**، مسیریابی خودکار هر Turn با استفاده از پروژه‌ی متن‌باز `jev-codex-bridge` راه‌اندازی می‌شه.
- برای **Claude Code داخل Claude Desktop**، برنامه مسیر نصب گرافیکی `Jev Model Router` رو آماده می‌کنه. این بخش در نسخه‌ی Alpha یک Plugin integration کمکیه و مثل مسیر Codex ادعای Transparent Proxy Routing برای هر Turn نداره.

این تفاوت داخل خود رابط برنامه هم واضح نمایش داده می‌شه؛ بخش Codex با برچسب `AUTOMATIC` و بخش Claude با برچسب `PLUGIN` مشخص شده.

## برای چه کاربری ساخته شده؟

مخاطب اصلی کسیه که بتونه یک برنامه رو دانلود کنه، `TypeSafe API key` رو Paste کنه و روی یک دکمه کلیک کنه. کاربر نباید برای استفاده‌ی معمول مجبور باشه `Node.js`، `npm` یا فایل‌های config رو دستی مدیریت کنه.

## راه‌اندازی سریع

### نسخه‌ی Portable Alpha

1. آخرین فایل Windows رو از بخش **Releases** دانلود کن.
2. فایل ZIP رو Extract کن.
3. روی `START_JEV_ROUTER.bat` دابل‌کلیک کن.
4. کلید `TypeSafe` رو Paste کن.
5. روی **Verify & save** کلیک کن.
6. برای Codex روی **Connect Codex** و برای Claude روی **Prepare Claude** بزن.

برای استفاده‌ی عادی نیازی به باز کردن Terminal نیست. اگر پیش‌نیازهای بخش Codex روی سیستم نباشن، برنامه بعد از تایید کاربر می‌تونه اون‌ها رو در پس‌زمینه با `WinGet` نصب کنه.

## نسخه‌ی CLI

همین راه‌اندازی به‌صورت تعاملی داخل PowerShell هم وجود داره. در اجرای اول، کلید `TypeSafe API key` با ورودی مخفی گرفته می‌شه، اعتبارش بررسی می‌شه، بعد با `Windows DPAPI` برای Windows user فعلی ذخیره می‌شه و برنامه می‌پرسه تنظیمات برای کدوم محیط انجام بشه.

برای نصب یک‌خطی:

</div>

```powershell
irm https://raw.githubusercontent.com/pouramin/jev-router-windows/main/install.ps1 | iex
```

<div dir="rtl" align="right">

بعد از نصب، یک PowerShell جدید باز کن و این دستور رو اجرا کن:

</div>

```powershell
jev-router
```

<div dir="rtl" align="right">

منوی CLI این گزینه‌ها رو داره:

</div>

```text
1 - ChatGPT / Codex Desktop (Codex routing)
2 - Claude / Claude Code
3 - Both
4 - Change TypeSafe API key
5 - Refresh status
6 - Reset Codex
7 - Reset Claude
8 - Reset everything
0 - Exit
```

<div dir="rtl" align="right">

برای Codex، نسخه‌ی CLI همون Bridge و تنظیمات دائمی Windows رو انجام می‌ده؛ بنابراین وقتی بعداً Codex Desktop رو باز کنی، تنظیمات Jev همچنان فعاله.

برای Claude، نسخه‌ی CLI متغیر مربوط به کلید رو آماده می‌کنه، Claude Desktop رو باز می‌کنه، Marketplace رو داخل Clipboard می‌ذاره و منتظر می‌مونه تا **Jev Model Router** رو از مسیر **Customize → Plugins** اضافه کنی. خود Claude برای Plugin حساب کاربری این تایید داخل برنامه رو اجباری کرده. بعد از اضافه‌شدن، Plugin در Claude Code sessionهای همون Claude account هم قابل استفاده‌ست.

## اتصال Codex

مسیر Codex در نسخه‌ی فعلی بیشترین میزان اتوماسیون رو داره.

وقتی روی **Connect Codex** کلیک می‌کنی، برنامه می‌تونه این کارها رو انجام بده:

1. وجود `Git`، `Node.js`، `Codex` و `Jev Bridge` رو بررسی کنه.
2. در صورت نیاز `Git` و `Node.js 24+` رو با `WinGet` نصب کنه.
3. پروژه‌ی `ansidium/jev-codex-bridge` رو از GitHub نصب کنه.
4. کلید `TypeSafe` رو در فایل موردنیاز Bridge قرار بده و دسترسی فایل رو تا جای ممکن به Windows user فعلی محدود کنه.
5. دستور نصب `jev-bridge` رو در پس‌زمینه اجرا کنه؛ خود Bridge قبل از تغییر config از تنظیمات Codex نسخه‌ی Backup می‌سازه.
6. Background Task موردنیاز Bridge رو در Windows ثبت کنه.
7. بعد از Restart برنامه‌ی Codex، گزینه‌ی `Jev Router` رو برای استفاده آماده کنه.

در این مسیر، Bridge از Login فعلی Codex استفاده می‌کنه و برنامه از کاربر `OpenAI API key` نمی‌خواد.

## اتصال Claude Code

برنامه‌ی `Claude Desktop` بخش گرافیکی `Claude Code` رو داره و Pluginها هم بین تجربه‌های Claude و Claude Code قابل استفاده هستن.

در نسخه‌ی Alpha، دکمه‌ی **Prepare Claude** این کارها رو انجام می‌ده:

1. متغیر `TYPESAFE_API_KEY` رو برای Windows user فعلی تنظیم می‌کنه تا Plugin بتونه کلید رو پیدا کنه.
2. این Marketplace رو داخل Clipboard کپی می‌کنه:

`Mandrilsquad1441/jev-model-router`

3. بخش Code در `Claude Desktop` رو باز می‌کنه.
4. مسیر گرافیکی دقیق نصب رو داخل خود برنامه نشون می‌ده:

**Customize → Plugins → Add → Add marketplace → paste → install Jev Model Router**

این بخش عمداً با برچسب `PLUGIN` نمایش داده می‌شه. در نسخه‌ی فعلی، `Jev Model Router` برای پیشنهاد و Delegation مدل استفاده می‌شه؛ این پروژه ادعا نمی‌کنه که Claude Desktop مثل Codex برای هر Turn به‌صورت Transparent پشت یک Proxy قرار گرفته.

## ریست و برگشت به حالت پیش‌فرض

هم نسخه‌ی گرافیکی و هم نسخه‌ی CLI گزینه‌های Reset دارن.

- گزینه‌ی **Reset Codex** تنظیمات Codex رو در صورت وجود Backup به حالت قبل برمی‌گردونه، Bridge و Background Service رو حذف می‌کنه و کلیدهای Jev/TypeSafe رو از فایل Bridge پاک می‌کنه.
- گزینه‌ی **Reset Claude** متغیرهای Jev/TypeSafe ساخته‌شده توسط این پروژه رو از Windows user پاک می‌کنه.
- گزینه‌ی **Reset everything** علاوه بر این‌ها، کلید محافظت‌شده‌ی TypeSafe که Jev Router با DPAPI ذخیره کرده رو هم حذف می‌کنه.

Pluginهای Claude در سطح Claude account ذخیره می‌شن. اگر **Jev Model Router** رو به حساب Claude اضافه کرده باشی و بخوای خود Plugin هم کاملاً حذف بشه، از مسیر **Customize → Plugins** گزینه‌ی Remove رو بزن.

## نگهداری TypeSafe API key

کلیدی که داخل برنامه وارد می‌کنی در حالت اصلی با **Windows DPAPI** و فقط برای Windows user فعلی ذخیره می‌شه.

برای سازگاری با ابزارهای فعلی 2 استثنا وجود داره:

- پروژه‌ی Codex Bridge از فایل `~/.jev-router.env` استفاده می‌کنه؛ برنامه تلاش می‌کنه ACL اون فایل رو فقط به کاربر فعلی محدود کنه.
- برای Plugin مربوط به Claude، در این نسخه‌ی Alpha از متغیر محیطی سطح User با نام `TYPESAFE_API_KEY` استفاده می‌شه.

قبل از استفاده روی کامپیوتر Shared یا پروژه‌های حساس، فایل [SECURITY.md](SECURITY.md) رو بخون.

## حریم خصوصی

برای اینکه Jev سختی و نوع درخواست رو تشخیص بده، بخشی از متن مرتبط با Routing باید برای TypeSafe ارسال بشه. درخواست اصلی Coding Agent هم مثل حالت معمول برای Provider خودش ارسال می‌شه.

مقدار دقیق Context و سیاست نگهداری اطلاعات به TypeSafe و Integration مورد استفاده بستگی داره. برای پروژه‌های خصوصی بهتره مستندات اون‌ها رو هم بررسی کنی.

## وضعیت پروژه

این نسخه **Alpha** است و هدفش ساده‌کردن تجربه‌ی Windows برای کاربر عادیه. پروژه عمداً از Integrationهای متن‌باز موجود استفاده می‌کنه و رفتار اون‌ها رو به اسم قابلیت اختصاصی خودش معرفی نمی‌کنه.

موارد فعلی:

- پشتیبانی از Windows 10 / 11
- بررسی واقعی `TypeSafe API key`
- ذخیره‌ی محلی کلید با `Windows DPAPI`
- نصب و حذف ساده‌ی Codex Bridge
- راه‌اندازی Background Service برای Codex
- راهنمای گرافیکی اتصال Claude Desktop
- صفحه‌ی وضعیت و تشخیص پیش‌نیازها
- پکیج Portable
- ساخت خودکار Release با GitHub Actions

موارد برنامه‌ریزی‌شده:

- Windows Installer امضاشده
- تشخیص دقیق‌تر وضعیت Plugin در Claude
- مسیر Automatic Routing برای Claude در صورتی که Extension point پایدار و قابل اتکایی برای تغییر Model در هر Turn در دسترس باشه
- Decision History و Router Health داخل خود برنامه
- سیستم Update برای خود برنامه

## اجرای سورس

رابط برنامه با `Windows PowerShell + WPF` نوشته شده تا برای اجرای نسخه‌ی Portable نیازی به Runtime جداگانه نباشه.

</div>

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\src\JevRouter.ps1
```

<div dir="rtl" align="right">

فایل `START_JEV_ROUTER.bat` رابط WPF رو با Windows PowerShell در پس‌زمینه اجرا می‌کنه؛ بنابراین کاربر عادی نیازی به باز کردن Terminal نداره.

## پروژه‌های Third-party

جزئیات داخل [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) نوشته شده.

## License

مجوز پروژه `MIT` است. فایل [LICENSE](LICENSE) رو ببین.

</div>
