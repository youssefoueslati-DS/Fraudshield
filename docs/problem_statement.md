# FraudShield: Problem Statement

## 1. The problem

Card fraud is the unauthorized use of a payment card or card details, usually to make purchases without the owner's permission.

Fraud harms everyone involved. Customers lose money at first and face the stress of a blocked card, even though they are usually refunded. The bank covers those refunds and the investigation costs, and risks losing customers' trust. Shops often lose both the goods and the payment when a purchase is reversed (a chargeback), and pay extra fees.

FraudShield assigns each incoming transaction a fraud risk score between 0 and 1, using patterns learned from hundreds of thousands of past transactions. Based on thresholds, each transaction is approved automatically, sent to a fraud analyst for review, or declined. Every score comes with an explanation of the main reasons behind it, so analysts can act quickly.

Detecting fraud is hard for several reasons. Fraud is rare (about 3.5% of transactions), so a naive model can approve everything and still look accurate while catching nothing. Both kinds of mistakes are costly: blocking legitimate customers damages trust, while missing fraud loses money. Fraudsters also change their tactics over time, so a model that works today may fail tomorrow. Finally, decisions must be made in milliseconds, while the customer waits.

## 2. The data

FraudShield uses the IEEE-CIS Fraud Detection dataset, released in a 2019 Kaggle competition organized by the IEEE Computational Intelligence Society. The data comes from Vesta Corporation, a company that processes online payments, so it contains real (anonymized) e-commerce transactions. It is one of the few public datasets of real payment fraud, which makes it a realistic and widely recognized benchmark.

The training data contains about 590,000 transactions with around 430 columns of information each. About 3.5% of the transactions are fraud, which makes the dataset strongly imbalanced.

Each transaction includes the amount, a relative timestamp, the product type, card information (type, category, anonymized number), billing address codes, and email domains. For about a quarter of transactions, a second table adds device and browser information. Several hundred additional anonymized features were engineered by Vesta. For privacy, there is no user ID, so FraudShield will construct a pseudo user ID from card, address, and email information.

**Limitation:** The data is from 2019, so current fraud patterns may differ. FraudShield addresses this with time-based validation, drift monitoring, and automatic retraining on new labels.

## 3. The costs of mistakes

**False positive (false alarm):** A legitimate customer's transaction is blocked or held for review. The customer is frustrated and may abandon the purchase or use another card, so the shop loses a sale and the bank loses its fee. Each review also costs analyst time. Customers who are blocked too often may leave the bank.

**False negative (missed fraud):** A fraudulent transaction is approved. The customer is usually refunded through a chargeback, so the bank and the shop absorb the loss: the stolen amount, the goods, and chargeback fees. The customer still faces stress and a cancelled card, and may lose trust in the bank.

Per case, a missed fraud is usually far more expensive than a false alarm. However, since about 96.5% of transactions are legitimate, false alarms can occur much more often, so their total cost adds up. FraudShield therefore aims to minimize the total cost of both errors, not just one of them. As a starting assumption, a missed fraud costs the transaction amount plus fees, and a false alarm costs a fixed amount for review and lost business. These values will be refined in Week 10.

## 4. How success is measured

Accuracy is misleading for this problem. Since only 3.5% of transactions are fraud, a model that approves every transaction would reach 96.5% accuracy while catching no fraud at all.

The main metric is PR-AUC (area under the precision–recall curve). Unlike ROC-AUC, which looks overly optimistic when the positive class is rare, PR-AUC focuses on how well the model handles fraud cases. Its random baseline equals the fraud rate (about 0.035), which gives an honest reference point. ROC-AUC will still be reported for comparison with other work, including the original Kaggle competition.

The decision threshold will be chosen to minimize the total cost of errors, based on the estimated costs of false positives and false negatives. At that threshold, FraudShield reports precision, recall, the confusion matrix, and the total cost. It also reports recall at a fixed precision (for example, the share of fraud caught when at least 50% of alerts are real fraud).

## 5. Success criteria

FraudShield's model is considered successful if its PR-AUC is clearly above the random baseline (about 0.035) and clearly above a simple baseline model (logistic regression). Each more advanced model must improve on the previous one. All results are measured on the most recent transactions, held out using a time-based split, so the model is always tested on data it has never seen, as it would be in real use.

Beyond the model, the full system is considered successful if it:

- scores each transaction in under 100 milliseconds, so the payment process is not interrupted;
- returns the main reasons behind every score, so analysts can understand and act on alerts;
- runs as a deployed, tested service with a public API;
- detects changes in fraud patterns (drift) and supports retraining on new labels.
