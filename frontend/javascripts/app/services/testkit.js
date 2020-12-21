/*
 * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

window.ChaiBioTech.ngApp.service('Testkit', [
  '$rootScope','$http',
  function($rootScope, $http) {

    this.result = [];
    this.amount = [];

    self = this;

    self.create = function(exp) {
        return $http.post("/experiments", {
          experiment: exp
        });
      };

    self.createWells = function(expId,well){
      return $http.put("/experiments/"+expId+"/wells",{
        wells:well
      });
    };

    self.getAmountArray = function(famCq, twoKits){
      var i = 0;
      this.amount  = [];
      this.amount[0] = (this.result[0] == "Invalid") ? "" : "";
      this.amount[1] = (this.result[1] == "Invalid") ? "" : "";

      for (i = 2; i < 8; i++) {
        if(this.result[i] == "Inhibited"){
          this.amount[i] = "";
        }
        else if(this.result[i] == "Invalid"){
          this.amount[i] = "";
        }
        else if (famCq[i]>=10 && famCq[i]<= 24) {
          this.amount[i] = "High";
        }
        else if (famCq[i]>24 && famCq[i]<= 30) {
          this.amount[i] = "Medium";
        }
        else if (famCq[i]>30 && famCq[i]<= 38) {
          this.amount[i] = "Low";
        }
        else{
          this.amount[i] = "Not Detectable";
        }
      }
      if(!twoKits){
        for (i = 8; i < 16; i++) {
          if(this.result[i] == "Inhibited"){
            this.amount[i] = "Invalid";
          }
          else if(this.result[i] == "Invalid"){
            this.amount[i] = "";
          }
          else if (famCq[i]>=10 && famCq[i]<= 24) {
            this.amount[i] = "High";
          }
          else if (famCq[i]>24 && famCq[i]<= 30) {
            this.amount[i] = "Medium";
          }
          else if (famCq[i]>30 && famCq[i]<= 38) {
            this.amount[i] = "Low";
          }
          else{
            this.amount[i] = "Not Detectable";
          }
        }
      }
      else{
        this.amount[8]="";
        this.amount[9]="";
        for (i = 10; i < 16; i++) {
          if(this.result[i] == "Inhibited"){
            this.amount[i] = "";
          }
          else if(this.result[i] == "Invalid"){
            this.amount[i] = "";
          }
          else if (famCq[i]>=10 && famCq[i]<= 24) {
            this.amount[i] = "High";
          }
          else if (famCq[i]>24 && famCq[i]<= 30) {
            this.amount[i] = "Medium";
          }
          else if (famCq[i]>30 && famCq[i]<= 38) {
            this.amount[i] = "Low";
          }
          else{
            this.amount[i] = "Not Detectable";
          }
        }
      }

      return this.amount;
    };

    self.getResultArray = function(famCq, hexCq, twoKits, omitPositive, omitNegative, negExist) {
      var i = 0;
      this.result = [];
      if(famCq[0]>=20 && famCq[0]<=34 ){
        this.result[0]="Valid";
      } else if(omitPositive){
        this.result[0]="Valid";
      } else{
        this.result[0]="Invalid";
      }

      if(omitNegative){
        this.result[0]="Omitted";
      } else if((!famCq[1] || famCq[1] == 0 || (famCq[1]>38 && famCq[1]<=40)) && (hexCq[1]>=20 && hexCq[1]<=36) ){
        this.result[1]="Valid";
      } else{
        this.result[1]="Invalid";
      }

      for (i = 2; i < 8; i++) {
        this.result[i]="Invalid";
        if(this.result[1] == "Invalid"){
          this.result[i]="Invalid";
        } else if(this.result[0] == "Valid" && this.result[1] == "Valid") {
          if(famCq[i]>=10 && famCq[i]<=38){
            this.result[i]="Positive";
          } else if ((!famCq[i]) && (hexCq[i]>=20 && hexCq[i]<=36)){
            this.result[i]="Negative";
          } else if (famCq[i] > 38 && (hexCq[i]>=20 && hexCq[i]<=36)){
            this.result[i]="Negative";
          } else {
            if((!famCq[i]) && (!hexCq[i])){
              this.result[i]="Inhibited";
            } else if(!(famCq[i]) && hexCq[i] > 36) {
              this.result[i]="Inhibited";
            } else if(famCq[i] > 38 && (!hexCq[i])){
              this.result[i]="Inhibited";
            } else if(famCq[i] > 38 && hexCq[i] > 36){
              this.result[i]="Inhibited";
            }
          }
        } else if(this.result[0] == "Valid" && this.result[1] == "Omitted" && negExist) {
          if(famCq[i]>=10 && famCq[i]<=38){
            this.result[i]="Positive";
          }
        } else if (this.result[1] == "Valid"){
          if((!famCq[i]) && (!hexCq[i])){
            this.result[i]="Inhibited";
          } else if(!(famCq[i]) && hexCq[i] > 36) {
            this.result[i]="Inhibited";
          } else if(famCq[i] > 38 && (!hexCq[i])){
            this.result[i]="Inhibited";
          } else if(famCq[i] > 38 && hexCq[i] > 36){
            this.result[i]="Inhibited";
          }
        }
      }
      if(!twoKits){
        for (i = 8; i < 16; i++) {
          this.result[i]="Invalid";
          if(this.result[1] == "Invalid"){
            this.result[i]="Invalid";
          } else if(this.result[0] == "Valid" && this.result[1] == "Valid") {
            if(famCq[i]>=10 && famCq[i]<=38){
              this.result[i]="Positive";
            } else if ((!famCq[i]) && (hexCq[i]>=20 && hexCq[i]<=36)){
              this.result[i]="Negative";
            } else if (famCq[i] > 38 && (hexCq[i]>=20 && hexCq[i]<=36)){
              this.result[i]="Negative";
            } else {
              if((!famCq[i]) && (!hexCq[i])){
                this.result[i]="Inhibited";
              } else if(!(famCq[i]) && hexCq[i] > 36) {
                this.result[i]="Inhibited";
              } else if(famCq[i] > 38 && (!hexCq[i])){
                this.result[i]="Inhibited";
              } else if(famCq[i] > 38 && hexCq[i] > 36){
                this.result[i]="Inhibited";
              }
            }
          } else if(this.result[0] == "Valid" && this.result[1] == "Omitted" && negExist) {
            if(famCq[i]>=10 && famCq[i]<=38){
              this.result[i]="Positive";
            }
          } else if (this.result[1] == "Valid"){
            if((!famCq[i]) && (!hexCq[i])){
              this.result[i]="Inhibited";
            } else if(!(famCq[i]) && hexCq[i] > 36) {
              this.result[i]="Inhibited";
            } else if(famCq[i] > 38 && (!hexCq[i])){
              this.result[i]="Inhibited";
            } else if(famCq[i] > 38 && hexCq[i] > 36){
              this.result[i]="Inhibited";
            }
          }
        }
      }
      else{
        if(famCq[8]>=20 && famCq[8]<=34 ){
          this.result[8]="Valid";
        } else if(omitPositive){
          this.result[8]="Valid";
        } else{
          this.result[8]="Invalid";
        }

        if(omitNegative){
          this.result[9]="Omitted";
        } else if((!famCq[9] || famCq[9] == 0 || (famCq[9]>38 && famCq[9]<=40)) && (hexCq[9]>=20 && hexCq[9]<=36) ){
          this.result[9]="Valid";
        } else{
          this.result[9]="Invalid";
        }

        for (i = 10; i < 16; i++) {
          this.result[i]="Invalid";
          if(this.result[9] == "Invalid"){
            this.result[i]="Invalid";
          } else if(this.result[8] == "Valid" && this.result[9] == "Valid") {
            if(famCq[i]>=10 && famCq[i]<=38){
              this.result[i]="Positive";
            } else if ((!famCq[i]) && (hexCq[i]>=20 && hexCq[i]<=36)){
              this.result[i]="Negative";
            } else if (famCq[i] > 38 && (hexCq[i]>=20 && hexCq[i]<=36)){
              this.result[i]="Negative";
            } else {
              if((!famCq[i]) && (!hexCq[i])){
                this.result[i]="Inhibited";
              } else if(!(famCq[i]) && hexCq[i] > 36) {
                this.result[i]="Inhibited";
              } else if(famCq[i] > 38 && (!hexCq[i])){
                this.result[i]="Inhibited";
              } else if(famCq[i] > 38 && hexCq[i] > 36){
                this.result[i]="Inhibited";
              }
            }
          } else if(this.result[8] == "Valid" && this.result[9] == "Omitted" && negExist) {
            if(famCq[i]>=10 && famCq[i]<=38){
              this.result[i]="Positive";
            }            
          } else if (this.result[9] == "Valid"){
            if((!famCq[i]) && (!hexCq[i])){
              this.result[i]="Inhibited";
            } else if(!(famCq[i]) && hexCq[i] > 36) {
              this.result[i]="Inhibited";
            } else if(famCq[i] > 38 && (!hexCq[i])){
              this.result[i]="Inhibited";
            } else if(famCq[i] > 38 && hexCq[i] > 36){
              this.result[i]="Inhibited";
            }
          }
        }
      }

      return this.result;
    };

    self.getCoronaResultArray = function(famCq, hexCq){
      var i = 0;
      this.result = [];
      if(famCq[0]>0){
        this.result[0]="Valid";
      } else {
        this.result[0]="Invalid";
      }

      if((!famCq[1] || famCq[1] == 0) && (hexCq[1]>0)){
        this.result[1]="Valid";
      } else{
        this.result[1]="Invalid";
      }

      for (i = 2; i < 16; i++) {
        this.result[i]="Invalid";
        if(this.result[1] == "Valid" && famCq[i]>0){
          this.result[i]="Positive";
        } else if(this.result[1] == "Invalid" && famCq[i]>0){
          this.result[i]="Invalid - NTC Control Failed";
        } else if(this.result[0] == "Valid" && hexCq[i]>0 && (!famCq[i] || famCq[i] == 0)){
          this.result[i]="Not Detected";
        } else if(this.result[0] == "Invalid" && hexCq[i]>0 && (!famCq[i] || famCq[i] == 0)){
          this.result[i]="Invalid - Positive Control Failed";
        } else if((!famCq[i] || famCq[i] == 0) && (!hexCq[i] || hexCq[i] == 0)){
          this.result[i]="Inhibited";
        }
      }
      return this.result;
    };

    self.getCovid19SurResultArray = function(famCq, hexCq){
      var i = 0;
      this.result = [];
      if(famCq[0]>0 && hexCq[0]>0){
        this.result[0]="Valid";
      } else {
        this.result[0]="Invalid";
      }

      if((!famCq[1] || famCq[1] == 0) && (!hexCq[1] || hexCq[1] == 0)){
        this.result[1]="Valid";
      } else{
        this.result[1]="Invalid";
      }

      for (i = 2; i < 16; i++) {
        this.result[i]="Invalid";
        if(this.result[1] == "Valid" && famCq[i]>0){
          this.result[i]="Positive";
        } else if(this.result[1] == "Invalid" && famCq[i]>0){
          this.result[i]="Invalid - NTC Control Failed";
        } else if(this.result[0] == "Valid" && hexCq[i]>0 && (!famCq[i] || famCq[i] == 0)){
          this.result[i]="Not Detected";
        } else if(this.result[0] == "Invalid" && hexCq[i]>0 && (!famCq[i] || famCq[i] == 0)){
          this.result[i]="Invalid - Positive Control Failed";
        } else if((!famCq[i] || famCq[i] == 0) && (!hexCq[i] || hexCq[i] == 0)){
          this.result[i]="Inhibited";
        }
      }
      return this.result;
    };
  }
]);
