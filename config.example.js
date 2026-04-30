// config.example.js
// このファイルはテンプレート（コミット対象）です。
// 実運用では .env から generate-config.ps1 で config.js を生成してください。
// 手動で config.js を作る場合は、このファイルを config.js にコピーして実値を入れてください。

window.APP_CONFIG = {
  googleMapsApiKey: "YOUR_GOOGLE_MAPS_API_KEY",
  firebase: {
    apiKey: "YOUR_FIREBASE_API_KEY",
    authDomain: "YOUR_PROJECT.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.firebasestorage.app",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
  }
};
