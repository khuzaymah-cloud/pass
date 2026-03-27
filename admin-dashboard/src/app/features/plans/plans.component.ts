import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';

@Component({
  selector: 'app-plans',
  standalone: true,
  imports: [CommonModule, DataTableComponent, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header"><h1>Plans</h1></div>
      @if (loading()) {
        <app-loading-spinner />
      } @else {
        <app-data-table [columns]="columns" [data]="tableData()" (action)="onAction($event)" />
      }
    </div>
  `,
  styles: [`.page { padding: 32px; } .page-header h1 { color: #fff; font-size: 24px; margin: 0 0 24px; }`]
})
export class PlansComponent implements OnInit {
  loading = signal(true);
  tableData = signal<Record<string, unknown>[]>([]);
  columns: TableColumn[] = [
    { key: 'name_en', label: 'Name' },
    { key: 'tier', label: 'Tier', type: 'badge', badgeColors: { silver: '#888', gold: '#FFD60A', platinum: '#AF52DE', diamond: '#00D4FF' } },
    { key: 'price_local', label: 'Price (JD)' },
    { key: 'daily_rate', label: 'Daily Rate' },
    { key: 'max_visits', label: 'Max Visits' },
    { key: 'gym_tier_access', label: 'Access Up To', type: 'badge', badgeColors: { standard: '#888', gold: '#FFD60A', platinum: '#AF52DE', diamond: '#00D4FF' } },
    { key: 'is_active', label: 'Active', type: 'boolean' },
    { key: 'id', label: 'Actions', type: 'actions' },
  ];

  private adminService = inject(AdminService);
  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading.set(true);
    this.adminService.getPlans().subscribe({
      next: (data) => { this.tableData.set(data as unknown as Record<string, unknown>[]); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  onAction(event: { action: string; row: Record<string, unknown> }): void {
    const id = event.row['id'] as string;
    const isActive = event.row['is_active'] as boolean;
    if (event.action === 'edit') {
      this.adminService.updatePlan(id, { is_active: !isActive }).subscribe(() => this.load());
    }
  }
}
