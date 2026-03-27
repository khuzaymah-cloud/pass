import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-stat-card',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="stat-card" [style.border-color]="color + '33'">
      <div class="stat-icon" [style.background]="color + '1a'" [style.color]="color">
        {{ icon }}
      </div>
      <div class="stat-info">
        <span class="stat-value">{{ value }}</span>
        <span class="stat-label">{{ label }}</span>
      </div>
    </div>
  `,
  styles: [`
    .stat-card {
      background: #111;
      border: 1px solid #222;
      border-radius: 12px;
      padding: 20px;
      display: flex;
      align-items: center;
      gap: 16px;
      transition: transform 0.2s, box-shadow 0.2s;
    }
    .stat-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 24px rgba(0,0,0,0.3);
    }
    .stat-icon {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 22px;
    }
    .stat-info { display: flex; flex-direction: column; }
    .stat-value { font-size: 24px; font-weight: 700; color: #fff; }
    .stat-label { font-size: 13px; color: #888; margin-top: 2px; }
  `]
})
export class StatCardComponent {
  @Input() icon = '';
  @Input() label = '';
  @Input() value: string | number = 0;
  @Input() color = '#00FF88';
}
