import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';

@Component({
  selector: 'app-gyms',
  standalone: true,
  imports: [CommonModule, FormsModule, DataTableComponent, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header">
        <h1>Gyms</h1>
        <div class="filters">
          <input type="text" [(ngModel)]="search" placeholder="Search gyms..."
                 (keyup.enter)="load()" class="search-input">
          <select [(ngModel)]="tierFilter" (change)="load()" class="filter-select">
            <option value="">All Tiers</option>
            <option value="standard">Standard</option>
            <option value="gold">Gold</option>
            <option value="platinum">Platinum</option>
            <option value="diamond">Diamond</option>
          </select>
        </div>
      </div>
      @if (loading()) {
        <app-loading-spinner />
      } @else {
        <app-data-table [columns]="columns" [data]="tableData()" (action)="onAction($event)" />
      }
    </div>
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
    .page-header h1 { color: #fff; font-size: 24px; margin: 0; }
    .filters { display: flex; gap: 8px; }
    .search-input, .filter-select {
      background: #111; border: 1px solid #333; border-radius: 8px; padding: 8px 12px;
      color: #fff; font-size: 14px; outline: none;
    }
    .search-input:focus, .filter-select:focus { border-color: #00FF88; }
  `]
})
export class GymsComponent implements OnInit {
  loading = signal(true);
  tableData = signal<Record<string, unknown>[]>([]);
  search = '';
  tierFilter = '';

  columns: TableColumn[] = [
    { key: 'name_en', label: 'Name' },
    { key: 'tier', label: 'Tier', type: 'badge', badgeColors: { standard: '#888', gold: '#FFD60A', platinum: '#AF52DE', diamond: '#00D4FF' } },
    { key: 'address', label: 'Address' },
    { key: 'is_active', label: 'Active', type: 'boolean' },
    { key: 'rating', label: 'Rating' },
    { key: 'id', label: 'Actions', type: 'actions' },
  ];

  private adminService = inject(AdminService);
  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading.set(true);
    this.adminService.getGyms(0, 100, this.tierFilter || undefined, undefined, this.search || undefined).subscribe({
      next: (data) => { this.tableData.set(data as unknown as Record<string, unknown>[]); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  onAction(event: { action: string; row: Record<string, unknown> }): void {
    const id = event.row['id'] as string;
    if (event.action === 'edit') {
      this.adminService.approveGym(id).subscribe(() => this.load());
    }
    if (event.action === 'delete' && confirm('Remove this gym?')) {
      this.adminService.deleteGym(id).subscribe(() => this.load());
    }
  }
}
