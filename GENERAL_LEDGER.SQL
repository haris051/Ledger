drop procedure if Exists PROC_GENERAL_LEDGER;
DELIMITER $$
CREATE PROCEDURE `PROC_GENERAL_LEDGER`( P_ACCOUNT_ID int,
										P_ENTRY_DATE_FROM TEXT,
										P_ENTRY_DATE_TO TEXT,
										P_START INT,
										P_LENGTH INT,
										P_COMPANY_ID INT,
										P_YEAR TEXT )
BEGIN

                    DECLARE BalanceFrom DECIMAL(22,2) Default 0;
                    Declare AccountType decimal Default 0;
                    Declare AccountId Text Default Null;
                    Declare AccountDescription Text Default '';
					Declare BalanceTo decimal(22,2) Default 0;
					Declare TotalDebit decimal(22,2) default 0;
					Declare TotalCredit decimal(22,2) default 0;
					Declare TotalBalance decimal(22,2) default 0;
					Declare DebitFrom decimal(22,2) default 0;
					Declare CreditFrom decimal(22,2) default 0;
                    
					
                    select 
                            ACC_ID,
							DESCRIPTION 
                    into
                            
                            AccountId,
                            AccountDescription 
                    from
                            accounts_id 
                    where
                            id=P_ACCOUNT_ID;
                    
                    
                    select 
                                account_type.ACCOUNT_ID
                    into 
                                AccountType 
                    from
                                accounts_id 
                    inner join
                                account_type
                    on
                                account_type.id=accounts_id.ACCOUNT_TYPE_ID
                    where 
                                accounts_id.id=P_ACCOUNT_ID;


					select 
                                Round(cast(IFNULL(SUM(BALANCE),0) as decimal(22,2)),2),
								Round(cast(IFNULL(SUM(Debit),0) as decimal(22,2)),2),
								Round(cast(IFNULL(SUM(Credit),0) as Decimal(22,2)),2)
                    into 
                                BalanceFrom,
								DebitFrom,
								CreditFrom								
                    from 
                                Daily_Account_Balance 
                    where 
                                Daily_Account_Balance.ENTRYDATE<DATE(P_ENTRY_DATE_FROM)
                    and 
                                Daily_Account_Balance.AccountId=P_ACCOUNT_ID;
                  
                    
					select 
                                Round(cast(IFNULL(SUM(DEBIT),0) as Decimal(22,2)),2),
								Round(cast(IFNULL(SUM(CREDIT),0) as Decimal(22,2)),2),
								Round(cast(IFNULL(SUM(Balance),0) as Decimal(22,2)),2)
                    into 
                                TotalDebit,
								TotalCredit,
								TotalBalance
                    from 
                                Daily_Account_Balance 
                    where 
                                Daily_Account_Balance.ENTRYDATE<=DATE(P_ENTRY_DATE_TO)
                    and 
                                Daily_Account_Balance.AccountId=P_ACCOUNT_ID;
					
					
							     							  
													   
								
								
					
								select 		
										
										A.id,
										A.FORM_FLAG,
										A.ACC_ID,
										A.DESCRIPTION,
										A.FORM_DATE,
										A.FORM_REFERENCE,
										A.FORM_TYPE,
										Round(cast(A.DEBIT as Decimal(22,2)),2) as DEBIT,
										Round(cast(A.CREDIT as Decimal(22,2)),2) as CREDIT,
										Round(cast(IFNULL(A.BALANCE,0) as Decimal(22,2)),2) as BALANCE,
										A.GL_FLAG,
										A.DETAIL_ID,
										A.FORM_ID,
										A.Total_Debit as Total_Debit,
										A.Total_Credit as Total_Credit,
										IFNULL(TotalBalance,0) as Total_Balance,
										IFNULL(A.BEG_BAL,0) as BEG_BAL,
										count(*) Over() as Total_Rows,
										AccountType as AccountType,
										IFNULL(DebitFrom,0) as DebitFrom,
                                        IFNULL(CreditFrom,0) as CreditFrom
										
								from (
								
								Select 
										'-1' as id,
										'BEG_BAL' as Form_Flag,
										AccountId AS ACC_ID,
										'' AS DESCRIPTION,
										Convert(P_ENTRY_DATE_FROM,Date) - Interval 1 year as FORM_DATE,
										''  as Form_Reference,
										'Beginning Balance'  as Form_TYPE,
										null  as Debit,
										null  as Credit,
										IFNULL(BalanceFrom,0) as Balance,
										'00'  as GL_FLAG ,
										'-1'  as Detail_Id,
										'0'   as FORM_ID,
										TotalDebit as Total_Debit,
										TotalCredit as Total_Credit,
										BalanceFrom as BEG_BAL
										
										Union all
										
								
										SELECT 
						
                                          A.id,
										  A.FORM_FLAG,
										  A.ACC_ID,
										  A.DESCRIPTION,
										  A.FORM_DATE,
										  A.FORM_REFERENCE,
										  CASE
										  
												WHEN A.GL_FLAG = 15 OR A.GL_FLAG = 16 OR A.GL_FLAG = 510 OR A.GL_FLAG = 511 THEN 'Payment Sent'
												WHEN A.GL_FLAG = 19 OR A.GL_FLAG = 20 OR A.GL_FLAG = 512 OR A.GL_FLAG = 513 THEN 'Receive Money'
												WHEN A.GL_FLAG = 101 OR A.GL_FLAG = 26 OR A.GL_FLAG = 23 OR A.GL_FLAG = 201 OR A.GL_FLAG = 102 OR A.GL_FLAG = 203 OR A.GL_FLAG = 103 OR A.GL_FLAG = 104 OR A.GL_FLAG = 105 OR A.GL_FLAG = 106 OR A.GL_FLAG = 5553 OR A.GL_FLAG=5554 THEN 'Payments'
												WHEN A.GL_FLAG = 107 OR A.GL_FLAG = 29 OR A.GL_FLAG = 28 OR A.GL_FLAG = 204 OR A.GL_FLAG = 205 OR A.GL_FLAG = 108 OR A.GL_FLAG = 109 OR A.GL_FLAG = 110 OR A.GL_FLAG = 111 OR A.GL_FLAG = 113 OR A.GL_FLAG = 114 OR A.GL_FLAG = 112 OR A.GL_FLAG = 5552 OR A.GL_FLAG =5551 THEN 'Receipts'
												WHEN A.GL_FLAG = 115 OR A.GL_FLAG = 89 OR A.GL_FLAG = 90 OR A.GL_FLAG = 116 OR A.GL_FLAG = 117 THEN 'CHARGES'
												WHEN A.GL_FLAG = 31 OR A.GL_FLAG = 32 OR A.GL_FLAG = 33 OR A.GL_FLAG = 34 THEN 'Partial Credit'
												WHEN A.GL_FLAG = 37 OR A.GL_FLAG = 38 THEN 'Receive Order'
												WHEN A.GL_FLAG = 39 OR A.GL_FLAG = 40 THEN 'Vendor Credit Memo'
												WHEN A.GL_FLAG = 41 OR A.GL_FLAG = 42 OR A.GL_FLAG = 43 OR A.GL_FLAG = 44 OR A.GL_FLAG = 79 OR A.GL_FLAG = 80 OR A.GL_FLAG = 81 THEN 'Sale Invoice'
												WHEN A.GL_FLAG = 45 OR A.GL_FLAG = 46 OR A.GL_FLAG = 47 OR A.GL_FLAG = 48  OR A.GL_FLAG = 82 OR A.GL_FLAG = 83 OR A.GL_FLAG = 84 THEN 'Sale Return'
												WHEN A.GL_FLAG = 49 OR A.GL_FLAG = 50 OR A.GL_FLAG = 51 OR A.GL_FLAG = 52 OR A.GL_FLAG = 53 OR A.GL_FLAG = 54 OR A.GL_FLAG = 55 OR A.GL_FLAG = 56  OR A.GL_FLAG = 85 OR A.GL_FLAG = 86 OR A.GL_FLAG = 87 OR A.GL_FLAG = 100 THEN 'Replacement'
												WHEN A.GL_FLAG = 57 OR A.GL_FLAG = 58 OR A.GL_FLAG = 59 OR A.GL_FLAG = 60 OR A.GL_FLAG = 150 OR A.GL_FLAG = 151 THEN 'Stock Transfer'
												WHEN A.GL_FLAG = 62  OR A.GL_FLAG = 64 THEN 'Stock In'
												WHEN A.GL_FLAG = 65 OR A.GL_FLAG = 66 OR A.GL_FLAG = 67 OR A.GL_FLAG = 68 OR A.GL_FLAG = 69 OR A.GL_FLAG = 70 THEN 'Adjustment'
												WHEN A.GL_FLAG = 71 OR A.GL_FLAG = 72 THEN 'General Journal'
												WHEN A.GL_FLAG = 75 OR A.GL_FLAG = 76 or A.GL_FLAG = 77 OR A.GL_FLAG = 78 THEN 'Repair IN'
												WHEN A.GL_FLAG = 73 OR A.GL_FLAG = 74 THEN 'Repair Out'
												When A.GL_FLAG = 5556 OR A.GL_FLAG = 5557 OR A.GL_FLAG = 5558 OR A.GL_FLAG = 5559 then 'Transient Inventory'
												WHEN A.GL_FLAG = 00 THEN 'BEGNING BALANCE'
												ELSE ''''
											
										  END as FORM_TYPE,
												A.DEBIT AS DEBIT,
											    A.CREDIT AS CREDIT,
										  '' as  BALANCE,
										  A.GL_FLAG,
										  A.DETAIL_ID,
										  A.FORM_ID,
										  IFNULL(TotalDebit,0) as Total_Debit,
										  IFNULL(TotalCredit,0) as Total_Credit,
										  IFNULL(BalanceFrom,0) as BEG_BAL
										  
									 FROM 
										(
								
										 
													SELECT 
															
															CASE
															
																	WHEN (A.GL_FLAG = 57) THEN A.AMOUNT
																	WHEN (A.GL_FLAG = 59) THEN A.AMOUNT
																	WHEN (A.GL_FLAG = 64) THEN A.AMOUNT
															        When (A.GL_FLAG = 5556) Then A.AMOUNT 
																	When (A.GL_FLAG = 5559) Then A.AMOUNT
																	
															END AS DEBIT,
														
															CASE
															
																	WHEN (A.GL_FLAG = 58)  THEN A.AMOUNT 
																	WHEN (A.GL_FLAG = 60)  THEN A.AMOUNT 
																	WHEN (A.GL_FLAG = 62)  THEN A.AMOUNT 
																	when (A.GL_FLAG = 150) Then A.Amount
																	When (A.GL_FLAG = 151) Then A.Amount
															        When (A.GL_FLAG = 5557) Then A.Amount 
																	when (A.GL_FLAG = 5558) Then A.Amount
																	
															END AS CREDIT,
																	A.GL_ACC_ID AS ACCOUNT_ID           ,
																	AccountId AS ACC_ID                 ,
																	AccountDescription AS DESCRIPTION   ,
																	AccountType AS ACCOUNT_TYPE_ID      ,
																	A.GL_FLAG                           ,
																	A.FORM_DATE                         ,
																	A.FORM_REFERENCE                    ,
																	A.Form_Id AS FORM_ID                ,
																	A.FORM_FLAG                         ,
																	A.ID                                ,
																	A.Form_Detail_Id AS DETAIL_ID 		 
													FROM 
																
															Stock_Accounting A
													WHERE 
													(
															CASE
															
																	WHEN P_COMPANY_ID <> "" 
																	THEN A.COMPANY_ID =P_COMPANY_ID
																	ELSE TRUE
															
															END
													
													AND
															
															CASE
															
																	WHEN P_ENTRY_DATE_TO <> "" 
																	THEN A.FORM_DATE <=P_ENTRY_DATE_TO
																	ELSE TRUE
															
															END
															
													And
													  
															CASE 
																
																   When P_ENTRY_DATE_FROM <> ""
																   Then A.FORM_DATE >=P_ENTRY_DATE_FROM
																   Else TRUE 
															  
															END
													AND
													
																A.GL_ACC_ID= P_ACCOUNT_ID	
													)
													
													-- Stock Accounting --

													UNION ALL

													-- Repair Accounting -- 								  

												   
													SELECT
															
															CASE
															
																	WHEN (A.GL_FLAG = 74) THEN A.AMOUNT 
																	WHEN (A.GL_FLAG = 75) THEN A.AMOUNT
															
															END AS DEBIT,
														
															CASE
															
																	WHEN (A.GL_FLAG = 73) THEN A.AMOUNT
																	WHEN (A.GL_FLAG = 76) THEN A.AMOUNT 
																	WHEN (A.GL_FLAG = 77) THEN A.AMOUNT 
																	WHEN (A.GL_FLAG = 78) THEN A.AMOUNT  
															
															END AS CREDIT                               ,
															
															A.GL_ACC_ID AS ACCOUNT_ID                   ,
															AccountId AS ACC_ID                         ,
															AccountDescription AS DESCRIPTION           ,
															AccountType AS ACCOUNT_TYPE_ID              ,
															A.GL_FLAG                                   ,
															A.FORM_DATE                                 ,
															A.FORM_REFERENCE                            ,
															A.Form_Id AS FORM_ID                        ,
															A.FORM_FLAG                                 ,
															A.ID                                        ,
															A.Form_Detail_Id AS DETAIL_ID               
													FROM
															Repair_Accounting A		
													WHERE 
															CASE
																	
																	WHEN P_COMPANY_ID <> "" 
																	THEN A.COMPANY_ID = P_COMPANY_ID
																	ELSE TRUE
															
															END
													
													AND 
													
															CASE
													
																	WHEN P_ENTRY_DATE_TO <> "" 
																	THEN A.FORM_DATE <= P_ENTRY_DATE_TO
																	ELSE TRUE
															
															END
													And

														    CASE 
															
																   When P_ENTRY_DATE_FROM <> ""
																   Then A.FORM_DATE >= P_ENTRY_DATE_FROM
																   Else TRUE 
														  
														    END
													AND
													
															A.GL_ACC_ID=P_ACCOUNT_ID

													
														  
														-- Repair Accounting -- 								  

														 UNION ALL

														-- Payments Accounting --											

													
													SELECT 
															
															CASE
													
																 WHEN (A.GL_FLAG = 510) then A.Amount			
																 When (A.GL_FLAG = 16)  then A.Amount
																 When (A.GL_FLAG = 513) then A.Amount
																 When (A.GL_FLAG = 19)  then A.Amount 
																 When (A.GL_FLAG = 26)  then A.Amount 
																 When (A.GL_FLAG = 201) then A.Amount
																 When (A.GL_FLAG = 203) then A.Amount 
																 When (A.GL_FLAG = 103) then A.Amount 
																 When (A.GL_FLAG = 105) then A.Amount
																 When (A.GL_FLAG = 107) then A.Amount
																 When (A.GL_FLAG = 204) then A.Amount			
																 When (A.GL_FLAG = 205) then A.Amount
																 When (A.GL_FLAG = 110) then A.Amount 
																 When (A.GL_FLAG = 113) then A.Amount 
																 When (A.GL_FLAG = 112) then A.Amount 
																 When (A.GL_FLAG = 5551) then A.Amount 
																 When (A.GL_FLAG = 89)  then A.Amount
																 When (A.GL_FLAG = 116) then A.Amount
																 When (A.GL_FLAG = 117) then A.Amount
																 When (A.GL_FLAG = 5553) then A.Amount
															
															END AS DEBIT                               ,
															CASE
															
																 When (A.GL_FLAG = 511) then A.Amount
																 When (A.GL_FLAG = 15)  then A.Amount
																 When (A.GL_FLAG = 512) then A.Amount 
																 When (A.GL_FLAG = 20)  then A.Amount
																 When (A.GL_FLAG = 101) then A.Amount 
																 When (A.GL_FLAG = 23)  then A.Amount
																 When (A.GL_FLAG = 102) then A.Amount 
																 When (A.GL_FLAG = 104) then A.Amount 
																 When (A.GL_FLAG = 106) then A.Amount
																 When (A.GL_FLAG = 29)  then A.Amount 
																 When (A.GL_FLAG = 28)  then A.Amount  
																 When (A.GL_FLAG = 108) then A.Amount 
																 When (A.GL_FLAG = 109) then A.Amount 
																 When (A.GL_FLAG = 111) then A.Amount 
																 When (A.GL_FLAG = 114) then A.Amount
																 When (A.GL_FLAG = 5552) then A.Amount 																 
																 When (A.GL_FLAG = 115) then A.Amount 
																 When (A.GL_FLAG = 90)  then A.Amount
																 When (A.GL_FLAG = 5554) then A.Amount
															
															END AS CREDIT                               ,
															
															A.GL_ACC_ID AS ACCOUNT_ID                   ,
															AccountId AS ACC_ID                         ,
															AccountDescription AS DESCRIPTION           ,
															AccountType AS ACCOUNT_TYPE_ID              ,
															A.GL_FLAG                                   ,
															A.FORM_DATE                                 ,
															A.FORM_REFERENCE                            ,
															A.Form_Id AS FORM_ID                        ,
															A.FORM_FLAG                                 ,
															A.ID                                        ,
															A.Form_Detail_Id AS DETAIL_ID               	
													FROM
															Payments_Accounting A		
													WHERE
													
													(
															CASE
													
																WHEN P_COMPANY_ID <> "" 
																THEN A.COMPANY_ID = P_COMPANY_ID
																ELSE TRUE
															
															END
													
													AND 
													
															CASE
															
																WHEN P_ENTRY_DATE_TO <> "" 
																THEN A.FORM_DATE <=P_ENTRY_DATE_TO
																ELSE TRUE
															
															END
													And 
													
															CASE 
															
																 When P_ENTRY_DATE_FROM <> ""
																 Then A.FORM_DATE >=P_ENTRY_DATE_FROM
																 Else TRUE 
														  
															END

													AND		
													
													
													A.GL_ACC_ID=P_ACCOUNT_ID
													)
													
													
														-- Payments Accounting --											


																UNION ALL

														-- Sales Accounting --

															  
													SELECT 
															
															CASE
															
																When (A.GL_FLAG = 41) then A.Amount
																When (A.GL_FLAG = 43) then A.Amount 
																When (A.GL_FLAG = 45) then A.Amount 
																When (A.GL_FLAG = 48) then A.Amount 
																When (A.GL_FLAG = 82) then A.Amount 
																When (A.GL_FLAG = 83) then A.Amount 
																When (A.GL_FLAG = 84) then A.Amount 
																When (A.GL_FLAG = 49) then A.Amount 
																When (A.GL_FLAG = 52) then A.Amount
																When (A.GL_FLAG = 100) then A.Amount 																
																When (A.GL_FLAG = 53) then A.Amount 
																When (A.GL_FLAG = 55) then A.Amount 
																                                           
															
															END AS DEBIT       			             ,
														  
														  CASE
															
															  When (A.GL_FLAG = 42) then A.Amount 
															  When (A.GL_FLAG = 44) then A.Amount 
															  When (A.GL_FLAG = 79) then A.Amount 
															  When (A.GL_FLAG = 80) then A.Amount 
															  When (A.GL_FLAG = 81) then A.Amount 
															  When (A.GL_FLAG = 46) then A.Amount 
															  When (A.GL_FLAG = 47) then A.Amount 
															  When (A.GL_FLAG = 50) then A.Amount 
															  When (A.GL_FLAG = 51) then A.Amount 
															  When (A.GL_FLAG = 54) then A.Amount 
															  when (A.GL_FLAG = 56) then A.Amount 
															  When (A.GL_FLAG = 86) then A.Amount 
															  When (A.GL_FLAG = 87) then A.Amount 
															  When (A.GL_FLAG = 85) then A.Amount 
														  
														  END AS CREDIT                                 ,
															  A.GL_ACC_ID AS ACCOUNT_ID             ,
															  AccountId AS ACC_ID                   ,
															  AccountDescription AS DESCRIPTION     ,
															  AccountType AS ACCOUNT_TYPE_ID        ,
															  A.GL_FLAG                             ,
															  A.FORM_DATE                           ,
															  A.FORM_REFERENCE                      ,
															  A.FORM_ID AS FORM_ID                  ,
															  A.FORM_FLAG                           ,
															  A.ID                                  ,
															  A.Form_Detail_Id AS DETAIL_ID         
													FROM          
																Sales_Accounting A
													WHERE
													
													(
															CASE
																
																WHEN P_COMPANY_ID <> ""
																THEN A.COMPANY_ID =P_COMPANY_ID
																ELSE TRUE
														  
															END
													
													AND
														  CASE
															
																WHEN P_ENTRY_DATE_TO <> "" 
																THEN A.FORM_DATE <=P_ENTRY_DATE_TO
																ELSE TRUE
														  
														  END
													And

														  CASE 
															   When P_ENTRY_DATE_FROM <> ""
															   Then A.FORM_DATE >= P_ENTRY_DATE_FROM
															   Else TRUE 
														  END

													AND		
													
														A.GL_ACC_ID=P_ACCOUNT_ID
													)
                                                       													
													
															-- Sales Accounting --

															 UNION ALL
															
																			
															-- Purchase Accounting --											
																		
													SELECT 
																					
															CASE
																					
																	When (A.GL_FLAG = 32) then A.Amount 
																	When (A.GL_FLAG = 33) then A.Amount 
																	When (A.GL_FLAG = 37) then A.Amount 
																	When (A.GL_FLAG = 39) then A.Amount 
														
															END AS DEBIT,
																
															CASE
																		 
																	 When (A.GL_FLAG = 31) then A.Amount 
																	 When (A.GL_FLAG = 34) then A.Amount 
																	 When (A.GL_FLAG = 38) then A.Amount 
																	 When (A.GL_FLAG = 40) then A.Amount 														 
																
															END AS CREDIT,
			
																	A.GL_ACC_ID AS ACCOUNT_ID,
																	AccountId AS ACC_ID,
																	AccountDescription AS DESCRIPTION,
																	AccountType AS ACCOUNT_TYPE_ID,
																	A.GL_FLAG,
																	A.FORM_DATE,
																	A.FORM_REFERENCE,
																	A.FORM_ID AS FORM_ID,
																	A.FORM_FLAG,
																	A.ID,
																	A.Form_Detail_Id AS DETAIL_ID 
													FROM 
																	Purchase_Accounting A		
													WHERE
													
													(
															CASE
													
																	WHEN P_COMPANY_ID <> "" THEN A.COMPANY_ID = P_COMPANY_ID
																	ELSE TRUE
															END
													
													AND 
													
															CASE
															
																	WHEN P_ENTRY_DATE_TO <> "" 
																	THEN A.FORM_DATE <= P_ENTRY_DATE_TO
																	ELSE TRUE
															
															END
													And 
													
															CASE 
															 	    When P_ENTRY_DATE_FROM <> ""
																    Then A.FORM_DATE >= P_ENTRY_DATE_FROM
																    Else TRUE 
															END

													AND
													
														A.GL_ACC_ID=P_ACCOUNT_ID	
                                                    ) 
																											
															-- Purchase Accounting --											



																 UNION ALL

															-- ADJUSTMENT Accounting--	
															
															
													SELECT
																
																CASE
																
																	 When (A.GL_FLAG = 66) then A.Amount 
																	 When (A.GL_FLAG = 67) then A.Amount 
																	 When (A.GL_FLAG = 69) then A.Amount
																	 When (A.GL_FLAG = 71) then A.Amount										
																
																END AS DEBIT								,
																
																CASE
																
																	 When (A.GL_FLAG = 65) then A.Amount 
																	 When (A.GL_FLAG = 68) then A.Amount 
																	 When (A.GL_FLAG = 70) then A.Amount 
																	 When (A.GL_FLAG = 72) then A.Amount  
																
																END AS CREDIT,
																	 
																	 A.GL_ACC_ID AS ACCOUNT_ID,
																	 AccountId AS ACC_ID,
																	 AccountDescription AS DESCRIPTION,
																	 AccountType AS ACCOUNT_TYPE_ID	,
																	 A.GL_FLAG,
																	 A.FORM_DATE,
																	 A.FORM_REFERENCE,
																	 A.FORM_ID AS FORM_ID,
																	 A.FORM_FLAG,
																	 A.ID,
																	 A.Form_Detail_Id AS DETAIL_ID
													FROM
													
																	Adjustment_Accounting  A
													
													WHERE
																CASE
													
																		WHEN P_COMPANY_ID <> ""
																		THEN COMPANY_ID = P_COMPANY_ID
																		ELSE TRUE
																   
																END
													
													
													AND
																CASE
													
																		WHEN P_ENTRY_DATE_TO <> ""
																		THEN FORM_DATE <= P_ENTRY_DATE_TO
																		ELSE TRUE
																
																END
													And 
													
																CASE 
																	   When P_ENTRY_DATE_FROM <> ""
																	   Then FORM_DATE >= P_ENTRY_DATE_FROM
																	   Else TRUE 
																END

													AND		
													
																GL_ACC_ID=P_ACCOUNT_ID
													    
														-- ADJUSTMENT Accounting--
                                                        
                                                      
										
										)A
                                        
										Union ALL 
										
										Select 
										'-2' as id,
										'Balance' as Form_Flag,
										'' AS ACC_ID,
										'' AS DESCRIPTION,
										Convert(P_ENTRY_DATE_TO,Date) + Interval 1 year as FORM_DATE,
										''  as Form_Reference,
										'Balance'  as Form_TYPE,
										IFNULL(TotalDebit,0)-IFNULL(DebitFrom,0)  as Debit,
										IFNULL(TotalCredit,0)-IFNULL(CreditFrom,0)  as Credit,
										IFNULL(TotalBalance,0)-IFNULL(BalanceFrom,0) as Balance,
										'00'  as GL_FLAG ,
										'-2'  as Detail_Id,
										'0'   as FORM_ID,
										TotalDebit as Total_Debit,
										TotalCredit as Total_Credit,
										BalanceFrom as BEG_BAL
										
										Union All 
										
										Select 
										'-3' as id,
										'Ending Balance' as Form_Flag,
										'' AS ACC_ID,
										'' AS DESCRIPTION,
										Convert(P_ENTRY_DATE_TO,Date) + Interval 2 year as FORM_DATE,
										''  as Form_Reference,
										'Ending Balance'  as Form_TYPE,
										 null  as Debit,
										 null  as Credit,
										IFNULL(TotalBalance,0) as Balance,
										'00'  as GL_FLAG ,
										'-3'  as Detail_Id,
										'0'   as FORM_ID,
										TotalDebit as Total_Debit,
										TotalCredit as Total_Credit,
										BalanceFrom as BEG_BAL
										
										
									)A Order by ISNULL(A.FORM_DATE),A.FORM_DATE asc
                                    	
									Limit P_START,P_LENGTH;
										
    
END $$
DELIMITER ;

