import { Component, OnDestroy, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { Title } from '@angular/platform-browser'
import { StatusService } from '../../../services/status/status.service'

@Component({
	templateUrl: './home.component.html',
	styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnDestroy, OnInit{

	constructor(
		private title: Title,
		private router: Router,
		private statusService: StatusService
	) {
		title.setTitle('ChaiPCR | Home')
	}

	onSetting(){
		this.statusService.stopSync()
		this.router.navigate(['/setting']);
	}

	onRunTestKit(){
		this.router.navigate(['/experiment/1']);
	}

	ngOnInit(){
		this.statusService.$data.subscribe(data => {
			this.processStatus(data);
		})
	}

	processStatus(data){
		const state = data.experiment_controller.machine.state;
		if(state !== 'idle'){
			const expId = data.experiment_controller.experiment.id
			if(expId){
				this.router.navigate([`/experiment/${expId}`]);
			}
		}
	}

	ngOnDestroy() {	}
}
