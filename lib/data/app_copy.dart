class CopyBlock {
  const CopyBlock({required this.title, required this.body});

  final String title;
  final String body;
}

class AppCopy {
  AppCopy._();

  static const brand = 'Volzi Play';
  static const version = '1.3.0';
  static const supportEmail = 'support@volziplay.com';
  static const legalEmail = 'legal@volziplay.com';
  static const copyrightYear = '2026';
  static const demoUrl = 'https://assets.afcdn.com/video49/20210722/v_645516.m3u8';
  static const tagline = 'A quieter way to watch';
  static const cinemaLine = 'Private library  ·  cinematic player';

  static const about = [
    CopyBlock(
      title: 'Who we are',
      body:
          'Volzi Play is a personal video library for iOS. You collect playable links you have the right to watch, organize them, and return to them with resume points, favorites, and playlists. The interface stays quiet so the picture comes first.',
    ),
    CopyBlock(
      title: 'What the app does',
      body:
          'Add M3U8, MP4, and other iOS-playable links to a local library. Continue unfinished titles, save favorites, build playlists with autoplay, search and sort your collection, and use a full player with skip, speed, loop, sleep timer, and cinema fullscreen.',
    ),
    CopyBlock(
      title: 'Design',
      body:
          'The palette is deep navy and glacial teal: cinematic, cool, and distinct from the usual gold-on-black look. Cinzel carries the English wordmark. El Messiri and Cairo keep titles and long reading elegant and easy on the eyes.',
    ),
    CopyBlock(
      title: 'What it does not do',
      body:
          'Volzi Play does not ship a content catalog, search for channels, or store video files on our servers. It is a local playback tool on your device. You are responsible for the legality of any link you paste and for having the right to watch it.',
    ),
    CopyBlock(
      title: 'Platform',
      body:
          'The app is iOS-only. It uses the system player so HLS adaptive streams and progressive files such as MP4 and MOV share one consistent experience.',
    ),
  ];

  static const privacy = [
    CopyBlock(
      title: 'Introduction',
      body:
          'We respect your privacy. This policy explains what Volzi Play handles, why, and what we do not collect. Using the app means you have read this notice. Last updated: September 2026.',
    ),
    CopyBlock(
      title: 'What we do not collect',
      body:
          'We do not require an account, ask for your name or phone number, run ad tracking, or sell data to third parties. The app does not upload watch links to a Volzi server for analysis.',
    ),
    CopyBlock(
      title: 'What stays on your device',
      body:
          'Titles, links, playlists, favorites, last playback positions, and your speed or skip preferences stay on this device. Nothing is uploaded to a Volzi server. You can rename, delete, or reset the library at any time from Settings.',
    ),
    CopyBlock(
      title: 'Network and content',
      body:
          'During playback your device connects directly to the address you entered. The content provider may see your IP address and request logs according to its own servers. Volzi Play does not control that provider’s policy and does not inspect the stream as it passes.',
    ),
    CopyBlock(
      title: 'Permissions',
      body:
          'The app needs internet access to load video. It may keep the screen awake while you watch so playback is not interrupted. We do not ask for Photos, Contacts, or Location.',
    ),
    CopyBlock(
      title: 'External links',
      body:
          'The contact page may open Mail on your device. When you leave Volzi Play, the privacy policy of that app or website applies.',
    ),
    CopyBlock(
      title: 'Children',
      body:
          'Volzi Play is a general playback tool and is not designed to collect data from children. If you are a parent or guardian, you are responsible for the links opened on the device.',
    ),
    CopyBlock(
      title: 'Changes',
      body:
          'We may update this policy when a new feature affects data. The date of the update will appear on this page. Continued use after an update means you have reviewed the new version.',
    ),
    CopyBlock(
      title: 'Contact',
      body:
          'For privacy questions write to legal@volziplay.com and include the app name, iOS version, and a clear description of your request.',
    ),
  ];

  static const terms = [
    CopyBlock(
      title: 'Acceptance',
      body:
          'By using Volzi Play you agree to these terms. If you do not agree, please do not use the app. The service is for iOS devices and for personal, non-commercial use unless we agree otherwise in writing.',
    ),
    CopyBlock(
      title: 'Nature of the service',
      body:
          'Volzi Play is a link player. We do not host video libraries, license the content you watch, or guarantee that every URL will always work. Playback depends on the source, format, network, and server rules.',
    ),
    CopyBlock(
      title: 'Your responsibility for links',
      body:
          'Use only links you have the right to watch or that are lawfully available to you. You may not use the app to play pirated material, content that infringes others’ rights, or anything unlawful in your country.',
    ),
    CopyBlock(
      title: 'Acceptable use',
      body:
          'Do not use the app to harm devices or networks, attempt to break into stream sources, or redistribute content beyond your rights. Unlawful use is solely your responsibility.',
    ),
    CopyBlock(
      title: 'Availability',
      body:
          'Playback may stop because of network loss, an expired URL, an unsupported format, or provider restrictions. We do not promise uptime for sources we do not operate.',
    ),
    CopyBlock(
      title: 'Disclaimer of warranty',
      body:
          'The app is provided as is, without express or implied warranties, including fitness for a particular purpose or freedom from errors. Picture and sound quality follow the original source, not our design layer.',
    ),
    CopyBlock(
      title: 'Limitation of liability',
      body:
          'To the fullest extent allowed by law, we are not liable for indirect damages, data loss, or interrupted viewing caused by external links, device faults, or iOS decisions.',
    ),
    CopyBlock(
      title: 'Ending use',
      body:
          'You may stop using the app at any time by deleting it. We may update these terms or stop distributing a future version if legal or technical needs require it.',
    ),
    CopyBlock(
      title: 'Governing law',
      body:
          'These terms are interpreted under the laws of your country of residence, without conflicting with the rules of the platforms that distribute the app. If one clause is held invalid, the rest remain in force.',
    ),
  ];

  static const copyright = [
    CopyBlock(
      title: 'App rights',
      body:
          'The Volzi Play name, visual mark, player, interface, and in-app copy are reserved for 2026. You may not copy the design or republish it as a separate product without permission.',
    ),
    CopyBlock(
      title: 'Content you play',
      body:
          'Video opened by a link does not belong to Volzi Play. Rights stay with their owners: producers, distributors, platforms, or whoever granted the license. The app is only a viewer on your device.',
    ),
    CopyBlock(
      title: 'Fair use and licenses',
      body:
          'If you play your own material or material licensed to you, you are exercising your rights. If a link leads to protected work without authorization, responsibility sits with the person using the link, not with the player itself.',
    ),
    CopyBlock(
      title: 'Fonts and assets',
      body:
          'We use Cairo, El Messiri, and Cinzel under their open designer licenses. Icons and images bundled with the app are for the Volzi Play identity.',
    ),
    CopyBlock(
      title: 'Reporting infringement',
      body:
          'If you hold rights and believe the app’s presentation or branding affects those rights, write to legal@volziplay.com with a description of the work, proof links, and a clear request. We cannot take down a video hosted by a third party because we do not store it.',
    ),
    CopyBlock(
      title: 'Notice',
      body:
          '© 2026 Volzi Play. All rights not expressly granted are reserved. VOLZI PLAY is a distinctive mark for the iOS player.',
    ),
  ];

  static const contact = [
    CopyBlock(
      title: 'How to reach us',
      body:
          'We welcome notes about playback, design, and legal pages. For general support use support@volziplay.com. For legal matters use legal@volziplay.com.',
    ),
    CopyBlock(
      title: 'What to include',
      body:
          'Mention app version 1.3.0, your iOS device and system version, the link format (such as M3U8 or MP4), and a description of what happens. Do not send unlawful content. We never need passwords for other accounts.',
    ),
    CopyBlock(
      title: 'Response times',
      body:
          'We aim to reply on business days to clear questions. Documented legal requests take priority over visual suggestions.',
    ),
    CopyBlock(
      title: 'What we do not provide',
      body:
          'We do not supply stream links, movie libraries, or account recovery for other platforms. If a specific URL fails, the source or the network is the first place to check.',
    ),
  ];

  static const howTo = [
    CopyBlock(
      title: 'Step 1 — Add to your library',
      body:
          'From Home or Library, add a playable HTTP or HTTPS link and an optional title. The item is stored on this device. A public sample stream is included so you can try the player immediately.',
    ),
    CopyBlock(
      title: 'Step 2 — Organize',
      body:
          'Rename titles, heart favorites, search the library, and sort by newest, name, unfinished, or most played. Create playlists and reorder items for a queue.',
    ),
    CopyBlock(
      title: 'Step 3 — Watch and resume',
      body:
          'Open any title to play. If you leave partway through, Continue watching and History bring you back to the last position. Playlists can autoplay the next item.',
    ),
    CopyBlock(
      title: 'Step 4 — Use the player tools',
      body:
          'Skip forward or back, change speed, loop, set a sleep timer, enter cinema fullscreen, and favorite from the player. Double-tap the left or right side of the picture to skip.',
    ),
    CopyBlock(
      title: 'If a link fails',
      body:
          'Check your internet, whether the URL has expired, and whether iOS supports the format. Some servers reject requests that need a token or a locked domain. Try the link in its original source first.',
    ),
  ];

  static const faq = [
    CopyBlock(
      title: 'Can I resume a video later?',
      body:
          'Yes. Volzi Play stores the last position on this device. Home shows Continue watching, and History lists everything you have started. You can turn resume off in Playback settings.',
    ),
    CopyBlock(
      title: 'How do playlists work?',
      body:
          'Create a list, add library items, reorder them, and play from the start. When a title ends, the next item can start automatically if Autoplay next is enabled.',
    ),
    CopyBlock(
      title: 'Does live M3U8 work?',
      body:
          'Yes. On iOS the player uses AVPlayer, which supports HLS. Encrypted streams with private keys, or ones locked to special HTTP headers, may fail.',
    ),
    CopyBlock(
      title: 'Are MP4 and other formats supported?',
      body:
          'Yes for iOS-compatible files such as MP4, MOV, M4V, and some audio files. WebM and AVI that the system cannot decode may not play.',
    ),
    CopyBlock(
      title: 'Are my videos uploaded to the cloud?',
      body:
          'No. Playback happens between your device and the link source. Library items, playlists, favorites, and resume points are local and can be deleted.',
    ),
    CopyBlock(
      title: 'Why does the screen stay awake?',
      body:
          'We keep the display awake in the player so a film or live stream is not interrupted. Normal sleep behavior returns when you leave.',
    ),
    CopyBlock(
      title: 'Is the app ad-free?',
      body:
          'This version shows no ads and does not require an account. The focus is quiet viewing.',
    ),
    CopyBlock(
      title: 'Is there an Android version?',
      body:
          'Not at the moment. Volzi Play is built as an iOS app so it can use the system player and the interface as designed.',
    ),
  ];

  static const formats = [
    CopyBlock(
      title: 'Adaptive streaming',
      body:
          'M3U8 and M3U over HLS are best for live playback and quality that follows network speed. That is the core use of a player like Volzi Play.',
    ),
    CopyBlock(
      title: 'Progressive files',
      body:
          'MP4 (H.264 or HEVC depending on the device), MOV, and M4V work when the file can stream progressively or download over HTTP/HTTPS.',
    ),
    CopyBlock(
      title: 'Audio',
      body:
          'You can try MP3, M4A, and AAC links in the same player while keeping the app’s visual identity.',
    ),
    CopyBlock(
      title: 'iOS limits',
      body:
          'The system does not play every container. Flash and some MKV or WebM files may be rejected. If setup fails, the player page shows an alert so you can go back and fix the URL.',
    ),
    CopyBlock(
      title: 'Protected addresses',
      body:
          'Links that need browser cookies or complex auth headers may not work from the URL alone. Volzi Play sends the request as a media player, not as a full browser.',
    ),
  ];

  static const disclaimer = [
    CopyBlock(
      title: 'General disclaimer',
      body:
          'Volzi Play is a viewing tool. We do not provide, pre-review, or guarantee content accuracy, availability, or suitability. Watching is at your own risk and according to your country’s laws and the source’s terms.',
    ),
    CopyBlock(
      title: 'Quality and technology',
      body:
          'Stuttering, audio drift, or a stalled stream may come from the network, the server, or the file encoding. That does not necessarily mean a fault in the app interface.',
    ),
    CopyBlock(
      title: 'Safety',
      body:
          'Do not paste links from sources you do not trust. As with any internet address, a malicious URL may lead to unwanted content. Check before you play.',
    ),
    CopyBlock(
      title: 'Commercial use',
      body:
          'Showing content in public places or rebroadcasting it may require extra licenses from rights holders. The app does not grant those licenses.',
    ),
  ];
}
