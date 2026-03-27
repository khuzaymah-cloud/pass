import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';
import { Checkin } from '../../core/models';

@Component({
  selector: 'app-checkins',
  standalone: true,
  imports: [CommonModule, DataTableComponent, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header"><h1>Check-ins</h1></div>
      @if (loading()) { <app-loading-spinner /> }
      @else { <app-data-table [columns]="columns" [data]="tableData()" (action)="onAction($event)" /> }
    </div>

    @if (showModal()) {
      <div class="modal-backdrop" (click)="showModal.set(false)">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h2>Check-in Details</h2>
            <button class="close-btn" (click)="showModal.set(false)">✕</button>
          </div>
          <div class="modal-body">
            @if (selected()) {
              <div class="detail-grid">
                <div class="detail-item"><span class="label">ID</span><span class="value id-val">{{ selected()!.id }}</span></div>
                <div class="detail-item"><span class="label">User ID</span><span class="value id-val">{{ selected()!.user_id }}</span></div>
                <div class="detail-item"><span class="label">Gym ID</span><span class="value id-val">{{ selected()!.gym_id }}</span></div>
                <div class="detail-item"><span class="label">Subscription ID</span><span class="value id-val">{{ selected()!.subscription_id }}</span></div>
                <div class="detail-item"><span class="label">Plan Tier</span><span class="value badge">{{ selected()!.plan_tier }}</span></div>
                <div class="detail-item"><span class="label">Rate Paid</span><span class="value">{{ selected()!.daily_rate_paid }} JD</span></div>
                <div class="detail-item"><span class="label">Status</span><span class="value badge" [style.color]="selected()!.status === 'completed' ? '#00FF88' : '#FFD60A'">{{ selected()!.status }}</span></div>
                <div class="detail-item"><span class="label">Checked In</span><span class="value">{{ selected()!.checked_in_at | date:'medium' }}</span></div>
                <div class="detail-item"><span class="label">Checked Out</span><span class="value">{{ selected()!.checked_out_at ? (selected()!.checked_out_at | date:'medium') : '—' }}</span></div>
                <div class="detail-item"><span class="label">QR Token</span><span class="value id-val">{{ selected()!.qr_token }}</span></div>
              </div>
            }
          </div>
        </div>
      </div>
    }
  `,
  styles: [`
    .page { padding: 32px; } .page-header h1 { color: #fff; font-size: 24px; margin: 0 0 24px; }
    .modal-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 1000; }
    .modal { background: #111; border: 1px solid #222; border-radius: 16px; width: 100%; max-width: 600px; max-height: 90vh; overflow-y: auto; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid #222; }
    .modal-header h2 { color: #fff; font-size: 20px; margin: 0; }
    .close-btn { background: none; border: none; color: #888; font-size: 20px; cursor: pointer; }
    .modal-body { padding: 24px; }
    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    .detail-item { display: flex; flex-direction: column; gap: 4px; }
    .label { color: #888; font-size: 12px; font-weight: 600; text-transform: uppercase; }
    .value { color: #fff; font-size: 14px; } .id-val { font-size: 11px; color: #666; word-break: break-all; }
    .badge { font-weight: 700; }
  `]
})
export class CheckinsComponent implements OnInit {
  loading = signal(true);
  checkins = signal<Checkin[]>([]);
  tableData = signal<Record<string, unknown>[]>([]);
  showModal = signal(false);
  selected = signal<Checkin | null>(null);
  columns: TableColumn[] = [
    { key: 'user_id', label: 'User ID' },
    { key: 'gym_id', label: 'Gym ID' },
    { key: 'plan_tier', label: 'Plan Tier', type: 'badge', badgeColors: { silver: '#888', gold: '#FFD60A', platinum: '#AF52DE', diamond: '#00D4FF' } },
    { key: 'daily_rate_paid', label: 'Rate Paid' },
    { key: 'status', label: 'Status', type: 'badge', badgeColors: { completed: '#00FF88', pending: '#FFD60A' } },
    { key: 'checked_in_at', label: 'Time', type: 'date' },
    { key: 'id', label: 'Actions', type: 'actions' },
  ];

  private adminService = inject(AdminService);
  ngOnInit(): void {
    this.adminService.getCheckins(0, 100).subscribe({
      next: (data: Checkin[]) => { this.checkins.set(data); this.tableData.set(data as unknown as Record<string, unknown>[]); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  onAction(event: { action: string; row: Record<string, unknown> }): void {
    const id = event.row['id'] as string;
    const item = this.checkins().find(c => c.id === id);
    if (item && (event.action === 'view' || event.action === 'edit')) { this.selected.set(item); this.showModal.set(true); }
  }
}
