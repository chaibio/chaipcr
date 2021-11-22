import { Component, Input, OnInit, ChangeDetectorRef, ViewChild, ElementRef, HostListener } from '@angular/core';
import { Router } from '@angular/router';
import { BreadCrumbsService, EmitPathEvent, BreadPaths } from '../../../services/breadcrumbs.service';
import Keyboard from "simple-keyboard";
import { UserModel } from '../users/user.model';
import { ConfirmModalService } from '../../../shared/modals/confirm-modal/confirm-modal.service';

@Component({
    templateUrl: './new-user.component.html',
    styleUrls: ['./new-user.component.scss']
})
export class NewUserComponent implements OnInit {

    public selectedField = "";
    public selectedTarget: any;
    public keyboard: Keyboard;
    public openKeyboard: boolean = false;
    public userData: UserModel;
    public inputPos: any;
    public settingContentElement: any;
    public fieldKeys: Array<string> = [];
    public passwordError: string = ''
    public confirmPasswordError: string = ''
    public passwordFocus: boolean = false
    public confirmPasswordFocus: boolean = false
    public hasChanges = false

    @ViewChild('container') container: ElementRef;

    constructor(
        private router: Router,
        private breadCrumbs: BreadCrumbsService,
        private changeDetector : ChangeDetectorRef,
        private confirmModalService: ConfirmModalService
    ) {}

    ngAfterViewInit() {
        this.keyboard = new Keyboard({
          onChange: input => this.onChange(input),
          onKeyPress: button => this.onKeyPress(button),
          theme: "hg-theme-default hg-theme-ios",
          layout: {
            default: [
              "q w e r t y u i o p {bksp}",
              "a s d f g h j k l {enter}",
              "{shift} z x c v b n m , . {shift}",
              "{alt} {space} {altright} {downkeyboard}"
            ],
            shift: [
              "Q W E R T Y U I O P {bksp}",
              "A S D F G H J K L {enter}",
              "{shiftactivated} Z X C V B N M , . {shiftactivated}",
              "{alt} {space} {altright} {downkeyboard}"
            ],
            alt: [
              "1 2 3 4 5 6 7 8 9 0 {bksp}",
              `@ # $ & * ( ) ' " {enter}`,
              "{shift} % - + = / ; : ! ? {shift}",
              "{default} {space} {back} {downkeyboard}"
            ],
          },
          display: {
            "{alt}": ".?123",
            "{shift}": "⇧",
            "{shiftactivated}": "🡅",
            "{enter}": "return",
            "{bksp}": "⌫",
            "{altright}": ".?123",
            "{downkeyboard}": "🞃",
            "{space}": " ",
            "{default}": "ABC",
            "{back}": "⇦"
          }          
        });
    }

    ngOnInit() {
        this.breadCrumbs.emit(new EmitPathEvent(BreadPaths.settingPath, [
            { name: 'Settings', current: false, path: '/setting' },
            { name: 'Manage Users', current: false, path: '/setting/users' },
            { name: 'New User', current: true, path: '/setting/users/new' },
        ]));

        this.userData = {
            id: 0,
            is_admin: false,
            name: '',
            email: '',
            password: '',
            confirm_password: ''
        };

        this.inputPos = {
            is_admin: 0,
            name: 94,
            email: 200,
            password: 306,
            confirm_password: 412,
            save: 518
        };

        this.fieldKeys = ['is_admin', 'name', 'email', 'password', 'confirm_password', 'save']
        this.selectedField = 'is_admin'

        this.settingContentElement = this.container.nativeElement.parentElement.parentElement;
    }

    @HostListener('mousedown', ['$event', '$event.target'])
    public onClick(event: MouseEvent, targetElement: HTMLElement): void {
        if (!targetElement) {
            return;
        }

        if(targetElement.classList.contains('new-user') || targetElement.classList.contains('nav-container') || targetElement.tagName.toLowerCase() == 'label'){
            this.openKeyboard = false;
            if(this.selectedTarget && this.selectedTarget.classList.contains("focus")){
                this.selectedTarget.classList.remove("focus");
            }
        }
    }

    onGoHome(){
        this.router.navigate(['/']);
    }

    onChange = (input: string) => {
        this.userData[this.selectedField] = input;
        this.hasChanges = true
    };

    onKeyPress = (button: string) => {
        this.openKeyboard = true;
        if (button.includes("{") && button.includes("}")) {
            this.handleLayoutChange(button);
        }
    }

    handleLayoutChange(button) {
        let currentLayout = this.keyboard.options.layoutName;
        let layoutName;

        switch (button) {
            case "{shift}":
            case "{shiftactivated}":
            case "{default}":
                layoutName = currentLayout === "default" ? "shift" : "default";
                break;

            case "{alt}":
            case "{altright}":
                layoutName = currentLayout === "alt" ? "default" : "alt";
                break;

            case "{smileys}":
                layoutName = currentLayout === "smileys" ? "default" : "smileys";
                break;
            case "{downkeyboard}":
                this.openKeyboard = false;
                break;
            default:
                break;
        }

        if (layoutName) {
            this.keyboard.setOptions({layoutName});
        }
    }

    onInputFocus(event, fieldName) {
        if(this.selectedTarget && this.selectedTarget.classList.contains("focus")){
            this.selectedTarget.classList.remove("focus");
        }

        this.selectedField = fieldName;
        this.selectedTarget = event.target;
        this.keyboard.setInput(event.target.value);
        this.openKeyboard = true;

        if(this.selectedTarget && !this.selectedTarget.classList.contains("focus")){
            this.selectedTarget.classList.add("focus");
        }

        switch (fieldName) {
            case "password":
                this.passwordFocus = true
                this.confirmPasswordFocus = false
                break;
            case "confirm_password":
                this.passwordFocus = false
                this.confirmPasswordFocus = true
                break;
            default:
                this.passwordFocus = false
                this.confirmPasswordFocus = false
                break;
        }

        this.changeDetector.detectChanges();
        this.settingContentElement.scrollTop = this.inputPos[this.selectedField]
    }

    onIsAdminSelect() {
        this.openKeyboard = false;
        this.selectedField = 'is_admin';
        if(this.selectedTarget && this.selectedTarget.classList.contains("focus")){
            this.selectedTarget.classList.remove("focus");
        }
        this.hasChanges = true
    }

    onSelectControl(direction){
        let currentIndex = 0
        let currentClass = ''
        if(direction){
            currentIndex = this.fieldKeys.indexOf(this.selectedField) - 1 < 0 ? 0 : this.fieldKeys.indexOf(this.selectedField) - 1
        } else {
            currentIndex = this.fieldKeys.indexOf(this.selectedField) + 1 >= this.fieldKeys.length ? this.fieldKeys.length - 1 : this.fieldKeys.indexOf(this.selectedField) + 1
        }
        currentClass = `user-${this.fieldKeys[currentIndex]}`
        if(currentIndex == 0 || currentIndex == this.fieldKeys.length - 1){
            this.selectedField = this.fieldKeys[currentIndex]
            this.settingContentElement.scrollTop = this.inputPos[this.selectedField]
            if(this.selectedTarget && this.selectedTarget.classList.contains("focus")){
                this.selectedTarget.classList.remove("focus");
            }
        } else {
            const inputElements: any = document.getElementsByClassName(currentClass);
            inputElements[0].focus();
            if(inputElements[1]) inputElements[1].focus();
        }
    }

    onCancel() {
        this.router.navigate(['/setting/users']);
    }

    onSaveChange() {
        this.hasChanges = false
        this.router.navigate(['/setting/users']);
    }

    passwordChanged(value) {
        this.userData.password = value
        if(this.userData.confirm_password && this.userData.confirm_password != this.userData.password){
            this.confirmPasswordError = 'Passwords must match'
        } else {
            this.confirmPasswordError = ''
        }
    }

    confirmPasswordChanged(value) {
        this.userData.confirm_password = value        
        if(this.userData.confirm_password && this.userData.confirm_password != this.userData.password){
            this.confirmPasswordError = 'Passwords must match'
        } else {
            this.confirmPasswordError = ''
        }
    }

    async confirmSaveData(){
        return await this.confirmModalService.confirm('Exit without saving?', 'Yes, Exit');
    }

}
