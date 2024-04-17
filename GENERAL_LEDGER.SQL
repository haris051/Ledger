drop procedure if Exists PROC_GENERAL_LEDGER;
DELIMITER $$
CREATE PROCEDURE `PROC_GENERAL_LEDGER`( P_ACCOUNT_ID INT,
										P_ENTRY_DATE_FROM TEXT,
										P_ENTRY_DATE_TO TEXT,
										P_START INT,
										P_LENGTH INT,
										P_COMPANY_ID INT,
										P_YEAR TEXT )
BEGIN

                    DECLARE BalanceFrom DECIMAL Default 0;
                    Declare AccountType decimal Default 0;
                    Declare AccountId decimal Default 0;
                    Declare AccountDescription Text Default '';
					Declare BalanceTo decimal Default 0;
					Declare TotalDebit decimal default 0;
					Declare TotalCredit decimal default 0;
                    
					
                    select 
                            ACC_ID					,
							DESCRIPTION 
                    into
                            
                            AccountId               ,
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
                                SUM(BALANCE) 
                    into 
                                BalanceFrom
                    from 
                                Daily_Account_Balance 
                    where 
                                Daily_Account_Balance.ENTRYDATE<DATE(P_ENTRY_DATE_FROM)
                    and 
                                Daily_Account_Balance.AccountId=P_ACCOUNT_ID;
                  
                    
					select 
                                SUM(DEBIT),
								SUM(CREDIT)
                    into 
                                TotalDebit,
								TotalCredit
                    from 
                                Daily_Account_Balance 
                    where 
                                Daily_Account_Balance.ENTRYDATE<DATE(P_ENTRY_DATE_TO)
                    and 
                                Daily_Account_Balance.AccountId=P_ACCOUNT_ID;
					
					
					
					
				
								select  
										SQL_NO_CACHE
										A.Unique_Rows,
										A.id,
										A.FORM_FLAG,
										A.ACC_ID,
										A.DESCRIPTION,
										A.FORM_DATE,
										A.FORM_REFERENCE,
										A.FORM_TYPE,
										A.DEBIT,
										A.CREDIT,
										A.TBalance + IFNULL(BalanceFrom,0)  as BALANCE,
										A.GL_FLAG,
										A.DETAIL_ID,
										A.FORM_ID,
										A.Total_Debit,
										A.Total_Credit,
										A.BEG_BAL,
										Count(*) Over() as Total_Rows
								from (
								select 		
										SQL_NO_CACHE
										A.Unique_Rows,
										A.id,
										A.FORM_FLAG,
										A.ACC_ID,
										A.DESCRIPTION,
										A.FORM_DATE,
										A.FORM_REFERENCE,
										A.FORM_TYPE,
										A.DEBIT,
										A.CREDIT,
										case 
											when A.id is null 
									    then 
											IFNULL(A.BALANCE,0)
									    else	
											SUM(A.Balance) OVER(Order by ISNULL(A.Unique_Rows),A.Unique_Rows asc)
										END
										as TBalance,
										A.GL_FLAG,
										A.DETAIL_ID,
										A.FORM_ID,
										A.Total_Debit,
										A.Total_Credit,
										A.BEG_BAL
							from (
							select 
										
										A.id,
										A.FORM_FLAG,
										A.ACC_ID,
										A.DESCRIPTION,
										A.FORM_DATE,
										A.FORM_REFERENCE,
										A.FORM_TYPE,
										A.DEBIT,
										A.CREDIT,
										A.BALANCE,
										A.GL_FLAG,
										A.DETAIL_ID,
										A.FORM_ID,
										A.Total_Debit,
										A.Total_Credit,
										A.BEG_BAL,
										Case when A.id is null then null else ROW_NUMBER() OVER (Order by ISNULL(A.id)) End as UNIQUE_ROWS
								from (
							 
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
												WHEN A.GL_FLAG = 101 OR A.GL_FLAG = 26 OR A.GL_FLAG = 23 OR A.GL_FLAG = 201 OR A.GL_FLAG = 102 OR A.GL_FLAG = 203 OR A.GL_FLAG = 103 OR A.GL_FLAG = 104 OR A.GL_FLAG = 105 OR A.GL_FLAG = 106  THEN 'Payments'
												WHEN A.GL_FLAG = 107 OR A.GL_FLAG = 29 OR A.GL_FLAG = 28 OR A.GL_FLAG = 204 OR A.GL_FLAG = 205 OR A.GL_FLAG = 108 OR A.GL_FLAG = 109 OR A.GL_FLAG = 110 OR A.GL_FLAG = 111 OR A.GL_FLAG = 113 OR A.GL_FLAG = 114 OR A.GL_FLAG = 112 THEN 'Receipts'
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
												WHEN A.GL_FLAG = 00 THEN 'BEGNING BALANCE'
												ELSE ''''
											
										  END AS FORM_TYPE,
										  case 
										  
												when IFNULL(A.DEBIT, 0)<0 then IFNULL(A.DEBIT, 0)*-1 else IFNULL(A.DEBIT,0) end AS DEBIT,
												
										  case 
										  
												when IFNULL(A.CREDIT, 0)<0 then IFNULL(A.CREDIT, 0)*-1 else IFNULL(A.CREDIT,0) end AS CREDIT,
										  CASE
												WHEN AccountType = 3 OR AccountType = 2 OR AccountType = 5 THEN SUM(IFNULL(A.DEBIT, 0)-IFNULL(A.CREDIT, 0))
												ELSE SUM(IFNULL(A.CREDIT, 0)-IFNULL(A.DEBIT, 0)) 			
										  END AS BALANCE,
										  A.GL_FLAG,
										  A.DETAIL_ID,
										  A.FORM_ID,
										  IFNULL(TotalDebit,0) as Total_Debit,
										  IFNULL(TotalCredit,0) as Total_Credit,
										  IFNULL(BalanceFrom,0) as BEG_BAL
									 FROM 
										(
										 select 
												*
										 From 
											(
													SELECT 
															
															CASE
															
																	WHEN (A.GL_FLAG = 57) THEN A.AMOUNT
																	WHEN (A.GL_FLAG = 59) THEN A.AMOUNT
																	WHEN (A.GL_FLAG = 64) THEN A.AMOUNT
															
															END AS DEBIT                                ,
														
															CASE
															
																	WHEN (A.GL_FLAG = 58)  THEN A.AMOUNT 
																	WHEN (A.GL_FLAG = 60)  THEN A.AMOUNT 
																	WHEN (A.GL_FLAG = 62)  THEN A.AMOUNT 
																	when (A.GL_FLAG = 150) Then A.Amount
																	When (A.GL_FLAG = 151) Then A.Amount
															
															END AS CREDIT                               ,
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
															CASE
															
																	WHEN P_COMPANY_ID <> "" 
																	THEN COMPANY_ID =P_COMPANY_ID
																	ELSE TRUE
															
															END
													
													AND
															
															CASE
															
																	WHEN P_ENTRY_DATE_TO <> "" 
																	THEN FORM_DATE <=Date(P_ENTRY_DATE_TO)
																	ELSE TRUE
															
															END
															
													And
													  
															CASE 
																
																   When P_ENTRY_DATE_FROM <> ""
																   Then FORM_DATE >=Date(P_ENTRY_DATE_FROM)
																   Else TRUE 
															  
															END
													AND
													
																GL_ACC_ID= P_ACCOUNT_ID		

													 
													
													-- Stock Accounting --

													UNION ALL

													-- Repair Accounting -- 								  

												   
													SELECT
															
															CASE
															
																	WHEN (A.GL_FLAG = 74) THEN A.AMOUNT 
																	WHEN (A.GL_FLAG = 75) THEN A.AMOUNT
															
															END AS DEBIT  		                        ,
														
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
																	THEN COMPANY_ID = P_COMPANY_ID
																	ELSE TRUE
															
															END
													
													AND 
													
															CASE
													
																	WHEN P_ENTRY_DATE_TO <> "" 
																	THEN FORM_DATE <= Date(P_ENTRY_DATE_TO)
																	ELSE TRUE
															
															END
													And

														    CASE 
															
																   When P_ENTRY_DATE_FROM <> ""
																   Then FORM_DATE >= Date(P_ENTRY_DATE_FROM)
																   Else TRUE 
														  
														    END
													AND
													
															GL_ACC_ID=P_ACCOUNT_ID	
														  
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
																 When (A.GL_FLAG = 102) then A.Amount 
																 When (A.GL_FLAG = 203) then A.Amount 
																 When (A.GL_FLAG = 103) then A.Amount 
																 When (A.GL_FLAG = 105) then A.Amount
																 When (A.GL_FLAG = 107) then A.Amount 
																 When (A.GL_FLAG = 205) then A.Amount
																 When (A.GL_FLAG = 110) then A.Amount 
																 When (A.GL_FLAG = 113) then A.Amount 
																 When (A.GL_FLAG = 112) then A.Amount 
																 When (A.GL_FLAG = 89)  then A.Amount
																 When (A.GL_FLAG = 116) then A.Amount
																 When (A.GL_FLAG = 117) then A.Amount
															
															END AS DEBIT                               ,
															CASE
															
																 When (A.GL_FLAG = 511) then A.Amount
																 When (A.GL_FLAG = 15)  then A.Amount
																 When (A.GL_FLAG = 512) then A.Amount 
																 When (A.GL_FLAG = 20)  then A.Amount
																 When (A.GL_FLAG = 101) then A.Amount 
																 When (A.GL_FLAG = 23)  then A.Amount
																 When (A.GL_FLAG = 201) then A.Amount 
																 When (A.GL_FLAG = 104) then A.Amount 
																 When (A.GL_FLAG = 106) then A.Amount
																 When (A.GL_FLAG = 29)  then A.Amount 
																 When (A.GL_FLAG = 28)  then A.Amount 
																 When (A.GL_FLAG = 204) then A.Amount 
																 When (A.GL_FLAG = 108) then A.Amount 
																 When (A.GL_FLAG = 109) then A.Amount 
																 When (A.GL_FLAG = 111) then A.Amount 
																 When (A.GL_FLAG = 114) then A.Amount 
																 When (A.GL_FLAG = 115) then A.Amount 
																 When (A.GL_FLAG = 90)  then A.Amount 														
															
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
															CASE
													
																WHEN P_COMPANY_ID <> "" 
																THEN COMPANY_ID = P_COMPANY_ID
																ELSE TRUE
															
															END
													
													AND 
													
															CASE
															
																WHEN P_ENTRY_DATE_TO <> "" 
																THEN FORM_DATE <=Date(P_ENTRY_DATE_TO)
																ELSE TRUE
															
															END
													And 
													
															CASE 
															
																 When P_ENTRY_DATE_FROM <> ""
																 Then FORM_DATE >=Date(P_ENTRY_DATE_FROM)
																 Else TRUE 
														  
															END

													AND		
													
													
													GL_ACC_ID=P_ACCOUNT_ID														
															  
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
																When (A.GL_FLAG = 53) then A.Amount 
																When (A.GL_FLAG = 55) then A.Amount 
																When (A.GL_FLAG = 100) then A.Amount                                            
															
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
														  
														  END AS CREDIT                             ,
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
															CASE
																
																WHEN P_COMPANY_ID <> ""
																THEN COMPANY_ID =P_COMPANY_ID
																ELSE TRUE
														  
															END
													
													AND
														  CASE
															
																WHEN P_ENTRY_DATE_TO <> "" 
																THEN FORM_DATE <=Date(P_ENTRY_DATE_TO)
																ELSE TRUE
														  
														  END
													And

														  CASE 
															   When P_ENTRY_DATE_FROM <> ""
															   Then FORM_DATE >= Date(P_ENTRY_DATE_FROM)
															   Else TRUE 
														  END

													AND		
													
														GL_ACC_ID=P_ACCOUNT_ID
														
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
															CASE
													
																	WHEN P_COMPANY_ID <> "" THEN COMPANY_ID = P_COMPANY_ID
																	ELSE TRUE
															END
													
													AND 
													
															CASE
															
																	WHEN P_ENTRY_DATE_TO <> "" 
																	THEN FORM_DATE <= Date(P_ENTRY_DATE_TO)
																	ELSE TRUE
															
															END
													And 
													
																CASE 
																	   When P_ENTRY_DATE_FROM <> ""
																	   Then FORM_DATE >= Date(P_ENTRY_DATE_FROM)
																	   Else TRUE 
																END

													AND
													
														GL_ACC_ID=P_ACCOUNT_ID																		 
																		   
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
																
																END AS CREDIT								,
																	 
																	 A.GL_ACC_ID AS ACCOUNT_ID				,
																	 AccountId AS ACC_ID					,
																	 AccountDescription AS DESCRIPTION		,
																	 AccountType AS ACCOUNT_TYPE_ID			,
																	 A.GL_FLAG								,
																	 A.FORM_DATE							,
																	 A.FORM_REFERENCE						,
																	 A.FORM_ID AS FORM_ID					,
																	 A.FORM_FLAG							,
																	 A.ID									,
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
																		THEN FORM_DATE <= Date(P_ENTRY_DATE_TO)
																		ELSE TRUE
																
																END
													And 
													
																CASE 
																	   When P_ENTRY_DATE_FROM <> ""
																	   Then FORM_DATE >= Date(P_ENTRY_DATE_FROM)
																	   Else TRUE 
																END

													AND		
													
																GL_ACC_ID=P_ACCOUNT_ID
													    
														-- ADJUSTMENT Accounting--
													
											)A Order by A.FORM_Date ASC
										) A
										group BY
										A.id,
										A.FORM_FLAG,
										A.ACC_ID,
										A.DESCRIPTION,
										A.FORM_DATE,
										A.FORM_REFERENCE,
										A.DEBIT,
										A.CREDIT,
										A.GL_FLAG,
										A.Detail_id,
										A.FORM_ID
										with ROLLUP 
										having A.id is null OR A.FORM_ID is not null
									
									  
										
									)A
									
									ORDER by ISNULL(A.Id)
								)A 
									
									Order by ISNULL(A.Unique_Rows),A.Unique_Rows asc
									)A
									LIMIT P_START,P_LENGTH;
									
									
									
									
									
										
    
END $$
DELIMITER ;
