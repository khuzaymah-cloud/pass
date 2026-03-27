import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';
import { Gym } from '../../core/models';

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
          <button class="btn-add" (click)="openCreate()">+ Add Gym</button>
        </div>
      </div>
      @if (loading()) {
        <app-loading-spinner />
      } @else {
        <app-data-table [columns]="columns" [data]="tableData()" (action)="onAction($event)" />
      }
    </div>

    @if (showModal()) {
      <div class="modal-backdrop" (click)="closeModal()">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h2>{{ modalMode() === 'create' ? 'Add Gym' : modalMode() === 'edit' ? 'Edit Gym' : 'Gym Details' }}</h2>
            <button class="close-btn" (click)="closeModal()">✕</button>
          </div>
          <div class="modal-body">
            @if (modalMode() === 'view' && selectedGym()) {
              <div class="detail-grid">
                <div class="detail-item"><span class="label">ID</span><span class="value id-val">{{ selectedGym()!.id }}</span></div>
                <div class="detail-item"><span class="label">Name (EN)</span><span class="value">{{ selectedGym()!.name_en }}</span></div>
                <div class="detail-item"><span class="label">Name (AR)</span><span class="value">{{ selectedGym()!.name_ar || '—' }}</span></div>
                <div class="detail-item"><span class="label">Tier</span><span class="value badge" [style.color]="tierColor(selectedGym()!.tier)">{{ selectedGym()!.tier }}</span></div>
                <div class="detail-item"><span class="label">Address</span><span class="value">{{ selectedGym()!.address }}</span></div>
                <div class="detail-item"><span class="label">Phone</span><span class="value">{{ selectedGym()!.phone || '—' }}</span></div>
                <div class="detail-item"><span class="label">Location</span><span class="value">{{ selectedGym()!.lat }}, {{ selectedGym()!.lng }}</span></div>
                <div class="detail-item"><span class="label">Active</span><span class="value">{{ selectedGym()!.is_active ? '✅ Yes' : '❌ No' }}</span></div>
                <div class="detail-item"><span class="label">Featured</span><span class="value">{{ selectedGym()!.is_featured ? '⭐ Yes' : 'No' }}</span></div>
                <div class="detail-item"><span class="label">Rating</span><span class="value">{{ selectedGym()!.rating }} ⭐ ({{ selectedGym()!.total_reviews }} reviews)</span></div>
                <div class="detail-item full"><span class="label">Description (EN)</span><span class="value">{{ selectedGym()!.description_en || '—' }}</span></div>
                <div class="detail-item full"><span class="label">Description (AR)</span><span class="value">{{ selectedGym()!.description_ar || '—' }}</span></div>
                <div class="detail-item full"><span class="label">Amenities</span><span class="value">{{ selectedGym()!.amenities?.join(', ') || '—' }}</span></div>
                <div class="detail-item full"><span class="label">Categories</span><span class="value">{{ selectedGym()!.categories?.join(', ') || '—' }}</span></div>
              </div>
              <div class="modal-actions">
                <button class="btn-edit" (click)="switchToEdit()">✏️ Edit</button>
                <button class="btn-approve" (click)="approveFromModal()" *ngIf="!selectedGym()!.is_active">✅ Approve</button>
                <button class="btn-danger" (click)="deleteFromModal()">🗑 Remove</button>
              </div>
            }
            @if (modalMode() === 'edit' || modalMode() === 'create') {
              <div class="form-grid">
                <div class="form-group"><label>Name (EN) *</label><input [(ngModel)]="form.name_en" placeholder="Gym name in English"></div>
                <div class="form-group"><label>Name (AR)</label><input [(ngModel)]="form.name_ar" placeholder="اسم النادي"></div>
                <div class="form-group"><label>Tier *</label>
                  <select [(ngModel)]="form.tier"><option value="standard">Standard</option><option value="gold">Gold</option><option value="platinum">Platinum</option><option value="diamond">Diamond</option></select>
                </div>
                <div class="form-group"><label>Phone</label><input [(ngModel)]="form.phone" placeholder="+962..."></div>
                <div class="form-group full"><label>Address *</label><input [(ngModel)]="form.address" placeholder="Full address"></div>
                <div class="form-group"><label>Latitude *</label><input type="number" [(ngModel)]="form.lat" step="0.0000001"></div>
                <div class="form-group"><label>Longitude *</label><input type="number" [(ngModel)]="form.lng" step="0.0000001"></div>
                <div class="form-group full"><label>Description (EN)</label><textarea [(ngModel)]="form.description_en" rows="3" placeholder="Description in English"></textarea></div>
                <div class="form-group full"><label>Description (AR)</label><textarea [(ngModel)]="form.description_ar" rows="3" placeholder="وصف بالعربية"></textarea></div>
                <div class="form-group full"><label>Amenities (comma separated)</label><input [(ngModel)]="form.amenities_str" placeholder="WiFi, Parking, Showers, Sauna"></div>
                <div class="form-group full"><label>Categories (comma separated)</label><input [(ngModel)]="form.categories_str" placeholder="Gym, CrossFit, Yoga, Swimming"></div>
                <div class="form-group"><label>Active</label>
                  <select [(ngModel)]="form.is_active"><option [ngValue]="true">Active</option><option [ngValue]="false">Inactive</option></select>
                </div>
                <div class="form-group"><label>Featured</label>
                  <select [(ngModel)]="form.is_featured"><option [ngValue]="true">Yes</option><option [ngValue]="false">No</option></select>
                </div>
              </div>
              @if (formError()) { <div class="form-error">{{ formError() }}</div> }
              <div class="modal-actions">
                <button class="btn-cancel" (click)="closeModal()">Cancel</button>
                <button class="btn-save" (click)="save()" [disabled]="saving()">
                  {{ saving() ? 'Saving...' : modalMode() === 'create' ? 'Create Gym' : 'Save Changes' }}
                </button>
              </div>
            }
          </div>
        </div>
      </div>
    }
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
    .page-header h1 { color: var(--text-primary); font-size: 24px; margin: 0; }
    .filters { display: flex; gap: 8px; align-items: center; }
    .search-input, .filter-select { background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 8px; padding: 8px 12px; color: var(--text-primary); font-size: 14px; outline: none; }
    .search-input:focus, .filter-select:focus { border-color: var(--accent); }
    .btn-add { background: var(--accent); color: var(--bg-primary); border: none; border-radius: 8px; padding: 8px 16px; font-weight: 700; cursor: pointer; font-size: 14px; white-space: nowrap; }
    .modal-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 1000; }
    .modal { background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px; width: 100%; max-width: 720px; max-height: 90vh; overflow-y: auto; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid var(--border); }
    .modal-header h2 { color: var(--text-primary); font-size: 20px; margin: 0; }
    .close-btn { background: none; border: none; color: var(--text-muted); font-size: 20px; cursor: pointer; }
    .modal-body { padding: 24px; }
    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }
    .detail-item { display: flex; flex-direction: column; gap: 4px; }
    .detail-item.full { grid-column: 1 / -1; }
    .label { color: var(--text-muted); font-size: 12px; font-weight: 600; text-transform: uppercase; }
    .value { color: var(--text-primary); font-size: 14px; }
    .id-val { font-size: 11px; color: #666; word-break: break-all; }
    .badge { font-weight: 700; }
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px; }
    .form-group { display: flex; flex-direction: column; gap: 6px; }
    .form-group.full { grid-column: 1 / -1; }
    .form-group label { color: var(--text-muted); font-size: 12px; font-weight: 600; }
    .form-group input, .form-group select, .form-group textarea { background: var(--bg-input); border: 1px solid var(--border-light); border-radius: 8px; padding: 10px 12px; color: var(--text-primary); font-size: 14px; outline: none; font-family: inherit; }
    .form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color: var(--accent); }
    .form-error { background: var(--error-bg); border: 1px solid var(--error-border); color: var(--error); padding: 8px 12px; border-radius: 8px; font-size: 13px; margin-bottom: 16px; }
    .modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
    .btn-cancel { background: var(--border); border: 1px solid var(--border-light); border-radius: 8px; padding: 10px 20px; color: var(--text-muted); cursor: pointer; font-size: 14px; }
    .btn-save { background: var(--accent); color: var(--bg-primary); border: none; border-radius: 8px; padding: 10px 20px; font-weight: 700; cursor: pointer; font-size: 14px; }
    .btn-save:disabled { opacity: 0.5; }
    .btn-edit { background: var(--border); border: 1px solid var(--info); border-radius: 8px; padding: 8px 16px; color: var(--info); cursor: pointer; font-size: 13px; }
    .btn-approve { background: var(--border); border: 1px solid var(--accent); border-radius: 8px; padding: 8px 16px; color: var(--accent); cursor: pointer; font-size: 13px; }
    .btn-danger { background: var(--border); border: 1px solid var(--error); border-radius: 8px; padding: 8px 16px; color: var(--error); cursor: pointer; font-size: 13px; }
  `]
})
export class GymsComponent implements OnInit {
  loading = signal(true);
  gyms = signal<Gym[]>([]);
  tableData = signal<Record<string, unknown>[]>([]);
  search = '';
  tierFilter = '';
  showModal = signal(false);
  modalMode = signal<'view' | 'edit' | 'create'>('view');
  selectedGym = signal<Gym | null>(null);
  saving = signal(false);
  formError = signal('');
  form = { name_en: '', name_ar: '', tier: 'standard', address: '', lat: 31.95, lng: 35.93, phone: '', description_en: '', description_ar: '', amenities_str: '', categories_str: '', is_active: false, is_featured: false };

  columns: TableColumn[] = [
    { key: 'name_en', label: 'Name' },
    { key: 'tier', label: 'Tier', type: 'badge', badgeColors: { standard: 'var(--text-muted)', gold: 'var(--warning)', platinum: '#AF52DE', diamond: 'var(--info)' } },
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
      next: (data: Gym[]) => { this.gyms.set(data); this.tableData.set(data as unknown as Record<string, unknown>[]); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  onAction(event: { action: string; row: Record<string, unknown> }): void {
    const id = event.row['id'] as string;
    const gym = this.gyms().find(g => g.id === id);
    if (!gym) return;
    if (event.action === 'view') { this.selectedGym.set(gym); this.modalMode.set('view'); this.showModal.set(true); }
    if (event.action === 'edit') { this.openEdit(gym); }
    if (event.action === 'delete' && confirm('Remove this gym?')) { this.adminService.deleteGym(id).subscribe(() => this.load()); }
  }

  openCreate(): void {
    this.form = { name_en: '', name_ar: '', tier: 'standard', address: '', lat: 31.95, lng: 35.93, phone: '', description_en: '', description_ar: '', amenities_str: '', categories_str: '', is_active: false, is_featured: false };
    this.formError.set(''); this.modalMode.set('create'); this.showModal.set(true);
  }

  openEdit(gym: Gym): void {
    this.selectedGym.set(gym);
    this.form = { name_en: gym.name_en, name_ar: gym.name_ar || '', tier: gym.tier, address: gym.address, lat: gym.lat, lng: gym.lng, phone: gym.phone || '', description_en: gym.description_en || '', description_ar: gym.description_ar || '', amenities_str: gym.amenities?.join(', ') || '', categories_str: gym.categories?.join(', ') || '', is_active: gym.is_active, is_featured: gym.is_featured };
    this.formError.set(''); this.modalMode.set('edit'); this.showModal.set(true);
  }

  switchToEdit(): void { const g = this.selectedGym(); if (g) this.openEdit(g); }

  save(): void {
    if (!this.form.name_en || !this.form.address) { this.formError.set('Name and address are required'); return; }
    this.saving.set(true);
    const body: Record<string, unknown> = {
      name_en: this.form.name_en, name_ar: this.form.name_ar || undefined, tier: this.form.tier,
      address: this.form.address, lat: this.form.lat, lng: this.form.lng,
      phone: this.form.phone || undefined, description_en: this.form.description_en || undefined,
      description_ar: this.form.description_ar || undefined,
      amenities: this.form.amenities_str ? this.form.amenities_str.split(',').map((s: string) => s.trim()) : [],
      categories: this.form.categories_str ? this.form.categories_str.split(',').map((s: string) => s.trim()) : [],
      is_active: this.form.is_active, is_featured: this.form.is_featured,
      opening_hours: { mon: { open: '06:00', close: '23:00' }, tue: { open: '06:00', close: '23:00' }, wed: { open: '06:00', close: '23:00' }, thu: { open: '06:00', close: '23:00' }, fri: { open: '06:00', close: '23:00' }, sat: { open: '08:00', close: '22:00' }, sun: { open: '08:00', close: '22:00' } },
    };
    const obs = this.modalMode() === 'create'
      ? this.adminService.createGym(body)
      : this.adminService.updateGym(this.selectedGym()!.id, body);
    obs.subscribe({
      next: () => { this.closeModal(); this.load(); },
      error: (e: { error?: { detail?: string } }) => { this.formError.set(e.error?.detail || 'Failed'); this.saving.set(false); },
    });
  }

  approveFromModal(): void {
    const g = this.selectedGym();
    if (g) this.adminService.approveGym(g.id).subscribe(() => { this.closeModal(); this.load(); });
  }

  deleteFromModal(): void {
    const g = this.selectedGym();
    if (g && confirm('Remove this gym?')) this.adminService.deleteGym(g.id).subscribe(() => { this.closeModal(); this.load(); });
  }

  closeModal(): void { this.showModal.set(false); this.selectedGym.set(null); this.saving.set(false); }

  tierColor(tier: string): string {
    const m: Record<string, string> = { standard: 'var(--text-muted)', gold: 'var(--warning)', platinum: '#AF52DE', diamond: 'var(--info)' };
    return m[tier] || 'var(--text-muted)';
  }
}
