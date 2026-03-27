import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AdminService } from '../../core/services/admin.service';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';
import { Country } from '../../core/models';

@Component({
  selector: 'app-countries',
  standalone: true,
  imports: [CommonModule, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header"><h1>Countries</h1></div>
      @if (loading()) { <app-loading-spinner /> }
      @else {
        <div class="grid">
          @for (c of countries(); track c.id) {
            <div class="country-card" [class.active]="c.is_active">
              <div class="country-header">
                <span class="code">{{ c.code }}</span>
                <span class="status" [class.on]="c.is_active">{{ c.is_active ? 'Active' : 'Inactive' }}</span>
              </div>
              <h3>{{ c.name_en }}</h3>
              <p class="ar">{{ c.name_ar }}</p>
              <div class="meta">
                <span>{{ c.currency_code }} ({{ c.currency_symbol_en }})</span>
                <span>VAT: {{ c.vat_rate }}%</span>
                <span>{{ c.phone_prefix }}</span>
              </div>
              <button class="toggle-btn" (click)="toggle(c)">
                {{ c.is_active ? 'Deactivate' : 'Activate' }}
              </button>
            </div>
          }
        </div>
      }
    </div>
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header h1 { color: #fff; font-size: 24px; margin: 0 0 24px; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px; }
    .country-card {
      background: #111; border: 1px solid #222; border-radius: 12px; padding: 20px;
      transition: all 0.2s;
    }
    .country-card.active { border-color: #00FF8844; }
    .country-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
    .code { background: #222; color: #fff; padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: 14px; }
    .status { font-size: 12px; font-weight: 600; color: #FF3B30; }
    .status.on { color: #00FF88; }
    h3 { color: #fff; margin: 0 0 2px; font-size: 18px; }
    .ar { color: #888; margin: 0 0 12px; font-size: 14px; }
    .meta { display: flex; gap: 12px; font-size: 12px; color: #666; margin-bottom: 16px; }
    .toggle-btn {
      width: 100%; padding: 8px; border-radius: 8px; border: 1px solid #333;
      background: none; color: #888; cursor: pointer; font-size: 13px;
    }
    .toggle-btn:hover { border-color: #00FF88; color: #00FF88; }
  `]
})
export class CountriesComponent implements OnInit {
  loading = signal(true);
  countries = signal<Country[]>([]);

  private adminService = inject(AdminService);
  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading.set(true);
    this.adminService.getCountries().subscribe({
      next: (data) => { this.countries.set(data); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  toggle(c: Country): void {
    this.adminService.toggleCountry(c.id, !c.is_active).subscribe(() => this.load());
  }
}
