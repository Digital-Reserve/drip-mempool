import { ChangeDetectionStrategy, Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';

@Component({
  selector: 'app-calculator',
  templateUrl: './calculator.component.html',
  styleUrls: ['./calculator.component.scss'],
  standalone: false,
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CalculatorComponent implements OnInit {
  form: FormGroup;

  constructor(
    private formBuilder: FormBuilder,
  ) { }

  ngOnInit(): void {
    this.form = this.formBuilder.group({
      bitcoin: [0],
      satoshis: [0],
    });

    this.form.get('bitcoin').valueChanges.subscribe((value) => {
      if (isNaN(value)) {
        return;
      }
      this.form.get('satoshis').setValue(Math.round(value * 100_000_000), { emitEvent: false });
    });

    this.form.get('satoshis').valueChanges.subscribe((value) => {
      const dripRate = (value / 100_000_000).toFixed(8);
      if (isNaN(value)) {
        return;
      }
      this.form.get('bitcoin').setValue(dripRate, { emitEvent: false });
    });

    // Default form with 1 DRIP
    this.form.get('bitcoin').setValue(1, { emitEvent: true });
  }

  transformInput(name: string): void {
    const formControl = this.form.get(name);
    if (!formControl.value) {
      return formControl.setValue('', {emitEvent: false});
    }
    let value = formControl.value.replace(',', '.').replace(/[^0-9.]/g, '');
    if (value === '.') {
      value = '0';
    }
    let sanitizedValue = this.removeExtraDots(value);
    if (name === 'bitcoin' && this.countDecimals(sanitizedValue) > 8) {
      sanitizedValue = this.toFixedWithoutRounding(sanitizedValue, 8);
    }
    if (sanitizedValue === '') {
      sanitizedValue = '0';
    }
    if (name === 'satoshis') {
      sanitizedValue = parseFloat(sanitizedValue).toFixed(0);
    }
    formControl.setValue(sanitizedValue, {emitEvent: true});
  }

  removeExtraDots(str: string): string {
    const [beforeDot, afterDot] = str.split('.', 2);
    if (afterDot === undefined) {
      return str;
    }
    const afterDotReplaced = afterDot.replace(/\./g, '');
    return `${beforeDot}.${afterDotReplaced}`;
  }

  countDecimals(numberString: string): number {
    const decimalPos = numberString.indexOf('.');
    if (decimalPos === -1) return 0;
    return numberString.length - decimalPos - 1;
  }

  toFixedWithoutRounding(numStr: string, fixed: number): string {
    const re = new RegExp(`^-?\\d+(?:.\\d{0,${(fixed || -1)}})?`);
    const result = numStr.match(re);
    return result ? result[0] : numStr;
  }

  selectAll(event): void {
    event.target.select();
  }
}
