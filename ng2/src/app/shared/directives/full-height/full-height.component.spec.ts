// import {
//   TestBed,
//   async,
//   inject,
//   ComponentFixture
// } from '@angular/core/testing'

// import { WindowRef } from '../..'
// import { FullHeightComponent } from './full-height.component'

// const mockWindowRef = {
//   nativeWindow: {
//     innerHeight: 500
//   }
// }

// describe('FullHeightComponent', () => {

//   let fixture: ComponentFixture<FullHeightComponent>;

//   beforeEach(async(() => {

//     TestBed.configureTestingModule({
//       providers: [
//         { provide: WindowRef, useValue: mockWindowRef }
//       ],
//       declarations: [
//         FullHeightComponent
//       ]
//     })

//   }))

//   it('should set element height to window height', async(() => {

//     const template = `<div full-height></div>`

//     TestBed.overrideTemplate(FullHeightComponent, template)

//     TestBed

//   }))

// })