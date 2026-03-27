import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-settings',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page">
      <div class="page-header">
        <h1>App Links & Settings</h1>
        <p>Public URLs and deep links for the 1Pass mobile app</p>
      </div>

      <div class="links-grid">
        <div class="link-card">
          <div class="link-icon">🌐</div>
          <div class="link-info">
            <h3>Website URL</h3>
            <a [href]="appUrl" target="_blank" class="link">{{ appUrl }}</a>
          </div>
          <button class="copy-btn" (click)="copy(appUrl)">📋 Copy</button>
        </div>

        <div class="link-card">
          <div class="link-icon">🍎</div>
          <div class="link-info">
            <h3>App Store (iOS)</h3>
            <a [href]="appStoreUrl" target="_blank" class="link">{{ appStoreUrl }}</a>
          </div>
          <button class="copy-btn" (click)="copy(appStoreUrl)">📋 Copy</button>
        </div>

        <div class="link-card">
          <div class="link-icon">🤖</div>
          <div class="link-info">
            <h3>Google Play (Android)</h3>
            <a [href]="playStoreUrl" target="_blank" class="link">{{ playStoreUrl }}</a>
          </div>
          <button class="copy-btn" (click)="copy(playStoreUrl)">📋 Copy</button>
        </div>

        <div class="link-card">
          <div class="link-icon">🔗</div>
          <div class="link-info">
            <h3>API Base URL</h3>
            <span class="link">{{ apiBaseUrl }}</span>
          </div>
          <button class="copy-btn" (click)="copy(apiBaseUrl)">📋 Copy</button>
        </div>

        <div class="link-card">
          <div class="link-icon">📱</div>
          <div class="link-info">
            <h3>Deep Link (Universal)</h3>
            <span class="link">{{ appUrl }}/app/open</span>
          </div>
          <button class="copy-btn" (click)="copy(appUrl + '/app/open')">📋 Copy</button>
        </div>

        <div class="link-card">
          <div class="link-icon">📖</div>
          <div class="link-info">
            <h3>API Documentation</h3>
            <a [href]="apiBaseUrl.replace('/v1', '/docs')" target="_blank" class="link">
              {{ apiBaseUrl.replace('/v1', '/docs') }}
            </a>
          </div>
          <button class="copy-btn" (click)="copy(apiBaseUrl.replace('/v1', '/docs'))">📋 Copy</button>
        </div>
      </div>

      <div class="info-section">
        <h2>Platform Info</h2>
        <div class="info-grid">
          <div class="info-item">
            <span class="info-label">Version</span>
            <span class="info-value">1.0.0</span>
          </div>
          <div class="info-item">
            <span class="info-label">Environment</span>
            <span class="info-value">{{ environment.production ? 'Production' : 'Development' }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">Default Country</span>
            <span class="info-value">{{ environment.defaultCountry }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">Launch Markets</span>
            <span class="info-value">JO → SA → AE → EG → KW → BH → QA → OM → IQ → SY → LB → PS</span>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header { margin-bottom: 32px; }
    .page-header h1 { color: #fff; font-size: 24px; margin: 0; }
    .page-header p { color: #888; margin-top: 4px; }
    .links-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(400px, 1fr)); gap: 12px; margin-bottom: 40px; }
    .link-card {
      background: #111; border: 1px solid #222; border-radius: 12px; padding: 16px 20px;
      display: flex; align-items: center; gap: 16px;
    }
    .link-icon { font-size: 28px; min-width: 40px; text-align: center; }
    .link-info { flex: 1; overflow: hidden; }
    .link-info h3 { color: #fff; font-size: 14px; margin: 0 0 4px; }
    .link {
      color: #00FF88; font-size: 13px; text-decoration: none;
      overflow: hidden; text-overflow: ellipsis; white-space: nowrap; display: block;
    }
    .link:hover { text-decoration: underline; }
    .copy-btn {
      background: #1a1a1a; border: 1px solid #333; border-radius: 8px; padding: 6px 12px;
      color: #888; cursor: pointer; font-size: 13px; white-space: nowrap;
    }
    .copy-btn:hover { border-color: #00FF88; color: #00FF88; }
    .info-section h2 { color: #fff; font-size: 20px; margin-bottom: 16px; }
    .info-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 12px; }
    .info-item {
      background: #111; border: 1px solid #222; border-radius: 8px; padding: 12px 16px;
      display: flex; justify-content: space-between; align-items: center;
    }
    .info-label { color: #888; font-size: 13px; }
    .info-value { color: #fff; font-size: 14px; font-weight: 600; }
  `]
})
export class SettingsComponent {
  environment = environment;
  appUrl = environment.appUrl;
  appStoreUrl = environment.appStoreUrl;
  playStoreUrl = environment.playStoreUrl;
  apiBaseUrl = environment.apiBaseUrl;

  copy(text: string): void {
    navigator.clipboard.writeText(text);
  }
}
